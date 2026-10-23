// Sign-in dialog for the public pages. Google One Tap alone shows nothing when
// it has been dismissed before, third-party cookies are off, or Safari blocks
// it, so "Sign in" opens this small dialog with Google's own button instead.
// Each page calls google.accounts.id.initialize() with its callback first.
(function () {
  var css = '.si-ov{position:fixed;inset:0;z-index:600;background:rgba(0,0,0,.45);display:flex;align-items:center;justify-content:center;padding:20px}' +
    '.si-box{background:var(--white,#fff);color:var(--black,#111);width:100%;max-width:360px;border-top:3px solid var(--red,#C4352A);padding:26px 24px 22px;text-align:center;box-shadow:0 12px 40px rgba(0,0,0,.25)}' +
    '.si-box h2{font-family:var(--serif,Georgia,serif);font-size:22px;margin:0 0 6px}' +
    '.si-box p{font-family:var(--sans,Helvetica,Arial,sans-serif);font-size:13px;color:var(--gray-500,#666);margin:0 0 18px;line-height:1.5}' +
    '.si-btn{display:flex;justify-content:center;min-height:44px}' +
    '.si-x{margin-top:16px;background:none;border:none;font-family:var(--sans,Helvetica,Arial,sans-serif);font-size:13px;color:var(--gray-500,#666);cursor:pointer;text-decoration:underline}';
  function ensureCss() {
    if (document.getElementById('si-css')) return;
    var st = document.createElement('style'); st.id = 'si-css'; st.textContent = css; document.head.appendChild(st);
  }
  window.utvCloseSignIn = function () {
    var ov = document.getElementById('si-ov'); if (ov) ov.remove();
    document.removeEventListener('keydown', onKey);
  };
  function onKey(e) { if (e.key === 'Escape') window.utvCloseSignIn(); }
  window.utvShowSignIn = function () {
    if (!window.google || !google.accounts || !google.accounts.id) {
      if (window.toast) toast('Sign-in is still loading. Try again in a moment.');
      return;
    }
    ensureCss(); window.utvCloseSignIn();
    var ov = document.createElement('div'); ov.className = 'si-ov'; ov.id = 'si-ov';
    ov.innerHTML = '<div class="si-box" role="dialog" aria-modal="true" aria-labelledby="si-h"><h2 id="si-h">Sign in</h2>' +
      '<p>Use your Google account to save stories and pick up where you left off in the app.</p>' +
      '<div class="si-btn" id="si-btn"></div><button class="si-x" type="button">Not now</button></div>';
    ov.addEventListener('click', function (e) { if (e.target === ov) window.utvCloseSignIn(); });
    ov.querySelector('.si-x').addEventListener('click', window.utvCloseSignIn);
    document.body.appendChild(ov);
    document.addEventListener('keydown', onKey);
    var dark = document.documentElement.getAttribute('data-theme') === 'dark';
    google.accounts.id.renderButton(document.getElementById('si-btn'), { type: 'standard', theme: dark ? 'filled_black' : 'outline', size: 'large', text: 'signin_with', shape: 'rectangular', width: 280 });
  };
})();
