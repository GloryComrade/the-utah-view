// A slim footer for article and static pages, which had none: the copyright
// line (same text as the front page's footer), a way to subscribe, and the
// Privacy / Delete account links. Fills <div id="miniFooter"></div>.
(function () {
  var el = document.getElementById('miniFooter'); if (!el) return;
  var D = window.UTV_SITE_DEFAULTS || {};
  var st = document.createElement('style');
  st.textContent = '.mini-foot{border-top:3px double var(--black);margin-top:24px;padding:18px 0 56px;font-family:var(--sans);font-size:12px;color:var(--gray-400);display:flex;flex-wrap:wrap;gap:10px 18px;align-items:center;justify-content:space-between}' +
    '.mini-foot nav{display:flex;flex-wrap:wrap;gap:6px 16px}.mini-foot a{color:var(--gray-500);text-decoration:none}.mini-foot a:hover{color:var(--red)}' +
    '.mini-foot .mf-sub{color:var(--red);font-weight:700}';
  document.head.appendChild(st);
  function draw(copy) {
    var e = function (x) { return String(x || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;'); };
    el.innerHTML = '<div class="container"><div class="mini-foot"><span>' + e(copy) + '</span><nav>' +
      '<a class="mf-sub" href="/#subscribe-section">Subscribe</a><a href="/?view=archive">Archive</a>' +
      '<a href="/privacy.html">Privacy Policy</a><a href="/delete-account.html">Delete my account</a></nav></div></div>';
  }
  draw(D.copyright || '');
  fetch('https://api.theutahview.com/api/config/site').then(function (r) { return r.json(); })
    .then(function (d) { if (d && d.value && d.value.copyright) draw(d.value.copyright); }).catch(function () {});
})();
