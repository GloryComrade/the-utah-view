// Cloudflare Pages Function: serves the static article page (site/article.html)
// for /article.html, but injects per-story Open Graph/Twitter tags so shared
// links preview the actual story (title + summary) instead of the generic page.
// Humans get the normal article page; crawlers get rich metadata.
export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const id = url.searchParams.get('id');
  // "/article", not "/article.html": Pages answers the .html path with a
  // pretty-URL redirect instead of the page.
  const shell = await env.ASSETS.fetch(new URL('/article', url));
  if (!id) return shell;
  let html = await shell.text();
  try {
    const r = await fetch('https://api.theutahview.com/api/stories/' + encodeURIComponent(id));
    if (r.ok) {
      const s = await r.json();
      const esc = (x) => String(x == null ? '' : x)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
      const title = esc(s.title || 'The Utah View');
      const desc = esc(String(s.summary || '').slice(0, 200));
      const author = esc(s.author || '');
      const og =
        '<title>' + title + ' | The Utah View</title>' +
        '<meta name="description" content="' + desc + '">' +
        '<meta property="og:type" content="article">' +
        '<meta property="og:site_name" content="The Utah View">' +
        '<meta property="og:title" content="' + title + '">' +
        '<meta property="og:description" content="' + desc + '">' +
        '<meta property="og:url" content="' + esc(url.href) + '">' +
        (author ? '<meta property="article:author" content="' + author + '">' : '') +
        '<meta name="twitter:card" content="summary">' +
        '<meta name="twitter:title" content="' + title + '">' +
        '<meta name="twitter:description" content="' + desc + '">';
      html = html.replace(/<title>[\s\S]*?<\/title>/i, og);
    }
  } catch (e) { /* fall back to the plain page */ }
  return new Response(html, {
    headers: { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'no-store' },
  });
}
