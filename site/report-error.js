// "Report an error": a line under each article that opens a short form. Reports
// go to POST /api/reports and show in the editor's Reader reports panel.
(function () {
  var API = 'https://api.theutahview.com';
  var css = '.rep-line{font-family:var(--sans);font-size:13px;color:var(--gray-500);margin:-24px 0 40px;padding-top:14px;border-top:1px solid var(--gray-200)}' +
    '.rep-line button{background:none;border:none;padding:0;font:inherit;color:var(--red);font-weight:600;cursor:pointer;text-decoration:underline}' +
    '.rep-ov{position:fixed;inset:0;z-index:600;background:rgba(0,0,0,.45);display:flex;align-items:flex-start;justify-content:center;padding:10vh 20px 20px}' +
    '.rep-ov[hidden]{display:none}' +
    '.rep-box{background:var(--white);color:var(--black);width:100%;max-width:520px;border-top:3px solid var(--red);box-shadow:0 12px 40px rgba(0,0,0,.25);padding:20px 22px;font-family:var(--sans)}' +
    '.rep-box h2{font-family:var(--serif);font-size:22px;margin:0 0 6px}.rep-box p{font-size:13px;color:var(--gray-500);margin:0 0 14px;line-height:1.5}' +
    '.rep-box label{display:block;font-size:12px;font-weight:700;color:var(--gray-700);margin:10px 0 4px}' +
    '.rep-box select,.rep-box textarea,.rep-box input{width:100%;box-sizing:border-box;padding:9px 10px;font:inherit;font-size:14px;border:1px solid var(--gray-200);background:var(--white);color:var(--black)}' +
    '.rep-box textarea{min-height:110px;resize:vertical}.rep-hp{position:absolute;left:-9999px;width:1px;height:1px;overflow:hidden}' +
    '.rep-acts{display:flex;gap:10px;justify-content:flex-end;margin-top:16px}' +
    '.rep-acts button{padding:9px 18px;font:inherit;font-size:13px;font-weight:700;cursor:pointer;border:1px solid var(--gray-200);background:var(--white);color:var(--gray-700)}' +
    '.rep-acts .rep-send{background:var(--red);border-color:var(--red);color:#fff}.rep-acts button:disabled{opacity:.5;cursor:default}' +
    '.rep-msg{font-size:13px;margin-top:10px;min-height:1em}.rep-msg.err{color:var(--red)}';
  var st = document.createElement('style'); st.textContent = css; document.head.appendChild(st);

  var ov = document.createElement('div');
  ov.className = 'rep-ov'; ov.hidden = true;
  ov.innerHTML = '<form class="rep-box" role="dialog" aria-modal="true" aria-labelledby="repTitle" novalidate>' +
    '<h2 id="repTitle">Report an error</h2>' +
    '<p>Tell us what’s wrong and our editors will check it. If we correct the story, we’ll say so at the end of it.</p>' +
    '<label for="repKind">What kind of problem?</label><select id="repKind"><option value="error">A factual error</option><option value="typo">A typo or wording problem</option><option value="broken">A broken link or image</option><option value="other">Something else</option></select>' +
    '<label for="repMsg">What’s wrong? Include the correct information and a source if you have one.</label><textarea id="repMsg" required maxlength="4000"></textarea>' +
    '<label for="repEmail">Your email (optional, if you’d like a reply)</label><input id="repEmail" type="email" autocomplete="email" maxlength="200">' +
    '<div class="rep-hp" aria-hidden="true"><label for="repWeb">Website</label><input id="repWeb" tabindex="-1" autocomplete="off"></div>' +
    '<div class="rep-msg" id="repStatus" role="status"></div>' +
    '<div class="rep-acts"><button type="button" id="repCancel">Cancel</button><button type="submit" class="rep-send" id="repSend">Send report</button></div></form>';
  var back = null;
  function $(id) { return document.getElementById(id); }
  function open() { back = document.activeElement; ov.hidden = false; document.body.style.overflow = 'hidden'; $('repStatus').textContent = ''; $('repStatus').className = 'rep-msg'; $('repSend').disabled = false; $('repSend').hidden = false; $('repMsg').focus(); }
  function close() { ov.hidden = true; document.body.style.overflow = ''; if (back && back.focus) back.focus(); }

  function init() {
    document.body.appendChild(ov);
    $('repCancel').addEventListener('click', close);
    ov.addEventListener('click', function (e) { if (e.target === ov) close(); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !ov.hidden) close(); });
    ov.querySelector('form').addEventListener('submit', function (e) {
      e.preventDefault();
      var msg = $('repMsg').value.trim(), s = $('repStatus');
      if (msg.length < 10) { s.textContent = 'Please describe the error in a sentence or two.'; s.className = 'rep-msg err'; $('repMsg').focus(); return; }
      $('repSend').disabled = true; s.textContent = 'Sending…'; s.className = 'rep-msg';
      fetch(API + '/api/reports', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({
        story_id: new URLSearchParams(location.search).get('id') || '', page_url: location.href,
        kind: $('repKind').value, message: msg, email: $('repEmail').value.trim(), website: $('repWeb').value
      }) }).then(function (r) { return r.json().then(function (d) { return { ok: r.ok, d: d }; }); })
        .then(function (x) {
          if (!x.ok) throw new Error((x.d && x.d.error) || 'failed');
          $('repMsg').value = ''; $('repSend').hidden = true; $('repCancel').textContent = 'Close';
          s.textContent = 'Thank you. Your report went to our editors.';
        }).catch(function (err) {
          $('repSend').disabled = false; s.className = 'rep-msg err';
          s.textContent = (err && err.message && err.message !== 'failed') ? err.message : 'Sorry, your report didn’t send. Please try again in a moment.';
        });
    });
    // The article is drawn after its data loads; add the line under it once.
    function place() {
      var b = document.querySelector('.article-body');
      if (!b || b.parentNode.querySelector('.rep-line')) return;
      var d = document.createElement('div');
      d.className = 'rep-line';
      d.innerHTML = 'Spot an error? <button type="button">Tell us</button> and our editors will check it.';
      d.querySelector('button').addEventListener('click', open);
      b.parentNode.insertBefore(d, b.nextSibling);
    }
    place();
    var host = $('articleContent');
    if (host) new MutationObserver(place).observe(host, { childList: true, subtree: true });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
