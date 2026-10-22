// Dark mode switch. The page follows the device setting until the visitor taps
// the sun/moon button in the top bar; their choice is remembered. Choosing the
// same theme as the device clears the choice, so the page follows the device
// again. (The theme itself is applied by a small script in each page's <head>.)
(function () {
  var KEY = 'utv_theme';
  var mq = window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null;
  var btn = null;
  var MOON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.5 14.2A8.5 8.5 0 0 1 9.8 3.5 8.5 8.5 0 1 0 20.5 14.2z"/></svg>';
  var SUN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="4.2"/><path d="M12 2.5v2.2M12 19.3v2.2M2.5 12h2.2M19.3 12h2.2M5.3 5.3l1.6 1.6M17.1 17.1l1.6 1.6M5.3 18.7l1.6-1.6M17.1 6.9l1.6-1.6"/></svg>';

  function stored() {
    try { var t = localStorage.getItem(KEY); return t === 'light' || t === 'dark' ? t : null; } catch (e) { return null; }
  }
  function device() { return mq && mq.matches ? 'dark' : 'light'; }
  function current() { return document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'light'; }
  function update() {
    if (!btn) return;
    var dark = current() === 'dark';
    btn.innerHTML = dark ? SUN : MOON;
    btn.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
    btn.title = btn.getAttribute('aria-label');
  }
  function apply(t) { document.documentElement.setAttribute('data-theme', t); update(); }
  function toggle() {
    var next = current() === 'dark' ? 'light' : 'dark';
    try { if (next === device()) localStorage.removeItem(KEY); else localStorage.setItem(KEY, next); } catch (e) {}
    apply(next);
  }

  // Follow the device live (e.g. its automatic evening switch) unless the visitor chose.
  if (mq) {
    var onChange = function () { if (!stored()) apply(device()); };
    if (mq.addEventListener) mq.addEventListener('change', onChange); else if (mq.addListener) mq.addListener(onChange);
  }

  function init() {
    var links = document.querySelector('.top-bar-links');
    if (!links) return;
    btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'theme-toggle';
    btn.addEventListener('click', toggle);
    links.appendChild(btn);
    update();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
