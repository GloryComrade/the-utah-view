// What the website shows for each Footer & Subscribe setting that hasn't been
// saved yet. Shared by index.html (to draw the footer) and editor.html (to fill
// its fields), so saving the panel without changes keeps the footer as it is.
window.UTV_SITE_DEFAULTS = {
  sub_overline: 'Stay briefed',
  sub_heading: 'Independent analysis, delivered monthly',
  sub_desc: 'The Utah View covers every region, every month — with the depth of a journal and the clarity of a briefing.',
  about_text: 'About',
  about_url: 'page.html?p=our-mission',
  copyright: '© 2026 The Utah View. All rights reserved. Salt Lake City, Utah.',
  footer_cols: [
    { title: 'Regions', links: [{ text: 'The Americas', url: '?cat=The Americas' }, { text: 'Europe', url: '?cat=Europe' }, { text: 'Asia-Pacific', url: '?cat=Asia-Pacific' }, { text: 'Middle East', url: '?cat=Middle East' }, { text: 'Africa', url: '?cat=Africa' }] },
    { title: 'Sections', links: [{ text: 'Lead Analysis', url: '?cat=Analysis' }, { text: 'Opinion', url: '?cat=Opinion' }, { text: 'Data Briefs', url: '?cat=Data' }] },
    { title: 'About', links: [{ text: 'Our Mission', url: 'page.html?p=our-mission' }, { text: 'Methodology', url: 'article.html?id=methodology' }, { text: 'Editorial Team', url: 'page.html?p=editorial-team' }, { text: 'Contact', url: 'page.html?p=contact' }] },
    { title: 'Follow', links: [{ text: 'Newsletter', url: '#subscribe-section' }] }
  ]
};
