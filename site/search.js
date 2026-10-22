// Site search: a "Search" link in the top bar (and the "/" key) opens a panel
// that finds stories as you type. Same rules as the app's search: every word
// must appear in the headline, author, region or summary (accents ignored);
// headline matches rank first, then author, region, summary, then newest.
(function () {
  var API = 'https://api.theutahview.com';
  var stories = null, loading = null, results = [], active = -1, returnFocus = null;

  var FOLD = { 'ł': 'l', 'ø': 'o', 'đ': 'd', 'ı': 'i', 'æ': 'ae', 'œ': 'oe', 'ß': 'ss', '‘': "'", '’': "'", '“': '"', '”': '"', '–': '-', '—': '-' };
  function fold(t) {
    return String(t || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
      .replace(/[łøđıæœß‘’“”–—]/g, function (c) { return FOLD[c]; });
  }
  function terms(q) {
    var seen = {};
    return fold(q).split(/\s+/).filter(function (w) { return w && !seen[w] && (seen[w] = true); });
  }
  function search(q) {
    var ts = terms(q);
    if (!ts.length || !stories) return [];
    var hits = [];
    stories.forEach(function (s, i) {
      var title = fold(s.title), author = fold(s.author), region = fold(s.region), summary = fold(s.summary), score = 0;
      for (var k = 0; k < ts.length; k++) {
        var t = ts[k], a = title.indexOf(t) >= 0, b = author.indexOf(t) >= 0, c = region.indexOf(t) >= 0, d = summary.indexOf(t) >= 0;
        if (!(a || b || c || d)) return;
        score += (a ? 8 : 0) + (b ? 4 : 0) + (c ? 3 : 0) + (d ? 1 : 0);
      }
      hits.push({ s: s, score: score, i: i });
    });
    hits.sort(function (x, y) {
      return y.score - x.score || String(y.s.date || '').localeCompare(String(x.s.date || '')) || x.i - y.i;
    });
    return hits.slice(0, 25).map(function (h) { return h.s; });
  }

  function esc(t) {
    return String(t == null ? '' : t).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
  // Highlight the search words in the headline (accent-insensitive).
  function mark(text, ts) {
    text = String(text || '');
    var f = fold(text), on = [];
    if (f.length !== text.length) return esc(text); // folding changed the length: skip highlighting
    ts.forEach(function (t) {
      for (var p = f.indexOf(t); p >= 0; p = f.indexOf(t, p + 1)) for (var j = p; j < p + t.length; j++) on[j] = true;
    });
    var out = '', open = false;
    for (var i = 0; i < text.length; i++) {
      if (on[i] && !open) { out += '<mark>'; open = true; }
      if (!on[i] && open) { out += '</mark>'; open = false; }
      out += esc(text[i]);
    }
    return out + (open ? '</mark>' : '');
  }
  function when(d) {
    if (!d) return '';
    var x = new Date(d + 'T00:00:00');
    return isNaN(x) ? '' : x.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  }

  function load() {
    if (stories) return Promise.resolve(stories);
    if (loading) return loading;
    loading = fetch(API + '/api/stories').then(function (r) { return r.json(); })
      .then(function (d) { stories = d.stories || []; return stories; })
      .catch(function () {
        try {
          var cache = JSON.parse(localStorage.getItem('utv_stories')) || {};
          stories = Object.keys(cache).map(function (id) { var s = cache[id]; s.id = s.id || id; return s; })
            .filter(function (s) { return !s.status || s.status === 'published'; });
        } catch (e) { stories = []; }
        return stories;
      });
    return loading;
  }

  var css = '' +
    '.srch-link{display:inline-flex;align-items:center;gap:5px;background:none;border:none;cursor:pointer;font:inherit;color:var(--gray-500,#666);padding:2px 8px}' +
    '.srch-link:hover{color:var(--red,#C4352A)}' +
    '.srch-overlay{position:fixed;inset:0;z-index:600;background:rgba(0,0,0,.45);display:flex;align-items:flex-start;justify-content:center;padding:8vh 20px 20px;animation:srch-fade .18s ease-out}' +
    '.srch-overlay[hidden]{display:none}' +
    '.srch-panel{background:var(--white,#fff);width:100%;max-width:680px;max-height:80vh;display:flex;flex-direction:column;border-top:3px solid var(--red,#C4352A);box-shadow:0 12px 40px rgba(0,0,0,.25);animation:srch-rise .18s ease-out}' +
    '.srch-head{display:flex;align-items:center;gap:10px;padding:14px 18px;border-bottom:1px solid var(--gray-200,#d4d4d4)}' +
    '.srch-head svg{flex-shrink:0;color:var(--gray-400,#888)}' +
    '.srch-input{flex:1;border:none;outline:none;font-family:var(--serif,Georgia,serif);font-size:20px;color:var(--black,#121212);background:transparent;min-width:0;-webkit-appearance:none;appearance:none}' +
    '.srch-input::-webkit-search-cancel-button,.srch-input::-webkit-search-decoration{-webkit-appearance:none;display:none}' +
    '.srch-close{border:none;background:none;font-size:28px;line-height:1;color:var(--gray-500,#666);cursor:pointer;padding:0 4px}' +
    '.srch-close:hover{color:var(--red,#C4352A)}' +
    '.srch-body{overflow-y:auto;padding:4px 18px 10px}' +
    '.srch-hint{font-family:var(--sans,Helvetica,Arial,sans-serif);font-size:13px;color:var(--gray-500,#666);padding:16px 0}' +
    '.srch-item{display:block;text-decoration:none;color:inherit;padding:12px 8px;margin:0 -8px;border-bottom:1px solid var(--gray-100,#eee)}' +
    '.srch-item:last-child{border-bottom:none}' +
    '.srch-item:hover,.srch-item.on{background:var(--gray-50,#f7f7f7)}' +
    '.srch-region{font-family:var(--sans,Helvetica,Arial,sans-serif);font-size:11px;font-weight:700;letter-spacing:1px;text-transform:uppercase;color:var(--red,#C4352A);margin-bottom:3px}' +
    '.srch-title{font-family:var(--serif,Georgia,serif);font-size:18px;font-weight:700;line-height:1.25;color:var(--black,#121212)}' +
    '.srch-title mark{background:var(--mark-bg,#F6DEDA);color:inherit;padding:0 1px}' +
    '.srch-by{font-family:var(--sans,Helvetica,Arial,sans-serif);font-size:12px;color:var(--gray-400,#888);margin-top:4px}' +
    '@keyframes srch-fade{from{opacity:0}to{opacity:1}}' +
    '@keyframes srch-rise{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:none}}' +
    '@media (max-width:600px){.srch-overlay{padding:0}.srch-panel{max-width:none;max-height:100vh;height:100%;border-top:none}.srch-link{padding:2px 6px}.srch-word{display:none}}' +
    '@media (max-width:400px){.top-bar-links{gap:3px!important}.top-bar-links a{padding:2px 5px!important}.srch-link{padding:2px 4px}}' +
    '@media (prefers-reduced-motion:reduce){.srch-overlay,.srch-panel{animation:none}}' +
    '@media print{.srch-link,.srch-overlay{display:none}}';
  var ICON = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="M20 20l-4.6-4.6"/></svg>';

  function el(id) { return document.getElementById(id); }

  function render() {
    var q = el('srchInput').value, body = el('srchBody'), ts = terms(q);
    active = -1;
    if (!ts.length) { results = []; body.innerHTML = '<div class="srch-hint">Search by headline, author or region.</div>'; return; }
    if (!stories) { body.innerHTML = '<div class="srch-hint">Loading stories…</div>'; return; }
    results = search(q);
    if (!results.length) { body.innerHTML = '<div class="srch-hint">No stories match “' + esc(q.trim()) + '”.</div>'; return; }
    body.innerHTML = '<div class="srch-hint" style="padding:10px 0 2px">' + results.length + (results.length === 25 ? '+' : '') + ' result' + (results.length === 1 ? '' : 's') + '</div>' +
      results.map(function (s, i) {
        var by = [s.author ? 'By ' + esc(s.author) : '', when(s.date)].filter(Boolean).join(' · ');
        return '<a class="srch-item" id="srchItem' + i + '" href="article.html?id=' + encodeURIComponent(s.id) + '">' +
          (s.region ? '<div class="srch-region">' + esc(s.region) + '</div>' : '') +
          '<div class="srch-title">' + mark(s.title, ts) + '</div>' +
          (by ? '<div class="srch-by">' + by + '</div>' : '') + '</a>';
      }).join('');
  }
  function highlight(i) {
    var prev = el('srchItem' + active); if (prev) prev.classList.remove('on');
    active = i;
    var cur = el('srchItem' + active); if (cur) { cur.classList.add('on'); cur.scrollIntoView({ block: 'nearest' }); }
  }

  function open() {
    var o = el('srchOverlay');
    if (!o.hidden) return;
    returnFocus = document.activeElement;
    o.hidden = false;
    document.body.style.overflow = 'hidden';
    el('srchInput').focus();
    el('srchInput').select();
    render();
    load().then(render);
  }
  function close() {
    var o = el('srchOverlay');
    if (o.hidden) return;
    o.hidden = true;
    document.body.style.overflow = '';
    if (returnFocus && returnFocus.focus) returnFocus.focus();
  }

  function init() {
    var st = document.createElement('style'); st.textContent = css; document.head.appendChild(st);
    var o = document.createElement('div');
    o.className = 'srch-overlay'; o.id = 'srchOverlay'; o.hidden = true;
    o.innerHTML = '<div class="srch-panel" role="dialog" aria-modal="true" aria-label="Search stories">' +
      '<div class="srch-head"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="M20 20l-4.6-4.6"/></svg>' +
      '<input class="srch-input" id="srchInput" type="search" placeholder="Search stories" autocomplete="off" aria-label="Search stories" aria-controls="srchBody">' +
      '<button class="srch-close" id="srchClose" aria-label="Close search">&times;</button></div>' +
      '<div class="srch-body" id="srchBody" aria-live="polite"></div></div>';
    document.body.appendChild(o);
    o.addEventListener('click', function (e) { if (e.target === o) close(); });
    el('srchClose').addEventListener('click', close);
    el('srchInput').addEventListener('input', render);
    el('srchInput').addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown' && results.length) { e.preventDefault(); highlight(Math.min(results.length - 1, active + 1)); }
      else if (e.key === 'ArrowUp' && results.length) { e.preventDefault(); highlight(Math.max(0, active - 1)); }
      else if (e.key === 'Enter' && results.length) { e.preventDefault(); location.href = 'article.html?id=' + encodeURIComponent(results[Math.max(0, active)].id); }
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') close();
      var t = e.target, typing = t && (t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName));
      if (e.key === '/' && !typing && !e.metaKey && !e.ctrlKey && !e.altKey) { e.preventDefault(); open(); }
    });
    var links = document.querySelector('.top-bar-links');
    if (links) {
      var b = document.createElement('button');
      b.type = 'button'; b.className = 'srch-link'; b.innerHTML = ICON + '<span class="srch-word">Search</span>';
      b.setAttribute('aria-label', 'Search stories'); b.title = 'Search (press /)';
      b.addEventListener('click', open);
      links.insertBefore(b, links.firstChild);
    }
  }
  window.openSearch = open;
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
