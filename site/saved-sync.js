// Saved stories follow the reader's account, the same way the apps do
// (GET/PUT /api/me/saved with the Google sign-in token). This browser keeps
// its own copy in localStorage, so saving still works offline or once the
// ~1 hour Google token has expired; the next sync merges the two lists.
(function () {
  var API = 'https://api.theutahview.com';
  function local() { try { return JSON.parse(localStorage.getItem('utv_saved')) || []; } catch (e) { return []; } }
  function token() { return localStorage.getItem('utv_token') || ''; }
  function signedIn() { try { return !!JSON.parse(localStorage.getItem('utv_user')) && !!token(); } catch (e) { return false; } }
  function put(ids) {
    return fetch(API + '/api/me/saved', { method: 'PUT', headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token() }, body: JSON.stringify({ ids: ids }) }).catch(function () {});
  }
  // Merge the account's list into this browser's (and back), then call done(changed).
  window.utvSyncSaved = function (done) {
    done = done || function () {};
    if (!signedIn()) { done(false); return; }
    fetch(API + '/api/me/saved', { headers: { 'Authorization': 'Bearer ' + token() } })
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (d) {
        if (!d || !Array.isArray(d.ids)) { done(false); return; }
        var mine = local(), union = mine.slice();
        d.ids.forEach(function (id) { id = String(id); if (union.indexOf(id) < 0) union.push(id); });
        var changed = union.length !== mine.length;
        if (changed) localStorage.setItem('utv_saved', JSON.stringify(union));
        if (union.length !== d.ids.length) put(union);
        done(changed);
      })
      .catch(function () { done(false); });
  };
  // Send this browser's list after a save or unsave.
  window.utvPushSaved = function () { if (signedIn()) put(local()); };
})();
// Article pages: refresh the Save button if the account had this story saved.
if (typeof window.loadArticle === 'function') window.utvSyncSaved(function (changed) { if (changed) window.loadArticle(); });
