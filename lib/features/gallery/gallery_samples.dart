import '../../core/api/models/models.dart';

/// Real headlines from api.theutahview.com, frozen for the design gallery
/// so it renders the same online, offline and in screenshot tests.
abstract final class GallerySamples {
  static const lead = Story(
    id: 'chinese-academics-begin-questioning-who-owns-the-batanes-isl',
    title: 'Chinese Academics Begin Questioning Who Owns the Batanes Islands',
    author: 'Benjamin Koh',
    region: 'Asia-Pacific',
    summary:
        'A University Symposium, a Deleted Web Page, and the Landmass That '
        'Commands the Luzon Strait',
    readTime: '3 min',
    date: '2026-07-22',
  );

  static const secondary = Story(
    id: 'aukus-does-australia-need-a-plan-b',
    title: 'AUKUS: Does Australia Need a Plan B?',
    author: 'Benjamin Koh',
    region: 'Asia-Pacific',
    summary:
        'Aging Submarines, Shipyard Delays, and a Proposal to Lease Japanese '
        'Diesel Boats as a Stopgap',
    readTime: '4 min',
    date: '2026-05-29',
  );

  static const europe = Story(
    id: 'zelenskyy-replaces-his-top-general-overnight',
    title: 'Zelenskyy Replaces His Top General Overnight',
    author: 'Benjamin Koh',
    region: 'Europe',
    summary:
        'Syrskyi Dismissed, Drapatyi Elevated, as the Front Grinds and Kyiv '
        'Runs Out of Patriots',
    readTime: '3 min',
    date: '2026-07-22',
  );

  static const americas = Story(
    id: 'maduro-gets-a-june-2027-trial-date-in-a-manhattan-courtroom',
    title: 'Maduro Gets a June 2027 Trial Date in a Manhattan Courtroom',
    author: 'Benjamin Koh',
    region: 'The Americas',
    summary:
        'Seized From Caracas in January, the Former President Now Faces a '
        'Jury — and a Sovereign-Immunity Fight First',
    readTime: '3 min',
    date: '2026-07-23',
  );

  static const middleEast = Story(
    id: 'iran-deal-deadlocked-at-24-billion-irgc-fires-warning-shots-',
    title:
        r'Iran Deal Deadlocked at $24 Billion; IRGC Fires Warning Shots at '
        'U.S. Destroyers',
    author: 'Benjamin Koh',
    region: 'Middle East',
    summary:
        "Rezaei Tells CNN the Ball Is in Trump's Court. CENTCOM Denies Any "
        r'Attack. Gas Hits $4.22.',
    readTime: '3 min',
    date: '2026-06-05',
  );

  static const africa = Story(
    id: 'ethiopia-and-eritrea-on-the-brink-of-war-again',
    title: 'Ethiopia and Eritrea: On the Brink of War Again',
    author: 'Benjamin Koh',
    region: 'Africa',
    summary:
        'The Tigray War Killed 600,000 People. Now Every Faction Is Rearming, '
        'and the Nobel Peace Prize Winner Wants a Port.',
    readTime: '2 min',
    date: '2026-05-26',
  );

  static const utah = Story(
    id: 'the-stratos-data-center-controversy',
    title: 'The Stratos Data Centre Controversy',
    author: 'Benjamin Koh',
    region: 'The Americas',
    summary:
        'A 40,000-Acre AI Data Center, a Shrinking Lake, and a Regulatory '
        'Framework Under Strain',
    readTime: '3 min',
    date: '2026-05-24',
  );

  static const draper = Story(
    id: 'draper-memorial-day-three-wars-one-monument-and-the-cost-of-',
    title:
        'Draper Memorial Day: Three Wars, One Monument, and the Cost of '
        'Volunteering',
    author: 'Benjamin Koh',
    region: 'The Utah Lens',
    summary:
        'A Gold Star Monument, a Korean War Veteran, and a Question of Who '
        'Understands Service',
    readTime: '3 min',
    date: '2026-05-25',
  );

  static const northKorea = Story(
    id: 'north-korea-builds-rocket-shelters-within-range-of-seoul',
    title: 'North Korea Builds Rocket Shelters Within Range of Seoul',
    author: 'Benjamin Koh',
    region: 'Asia-Pacific',
    summary:
        'Twenty-One New Structures Near Kaesong, Fifty Kilometers From the '
        'South Korean Capital',
    readTime: '3 min',
    date: '2026-07-22',
  );

  static const opinion = Story(
    id: 'the-algorithm-has-more-power-than-you-think',
    title: 'The Algorithm Has More Power Than You Think',
    author: 'Ryan Cheng',
    region: 'Global',
    summary:
        'Social media algorithms prioritize engagement over truth, giving a '
        'few tech companies dangerous, unaccountable power over how billions '
        'of people receive information — and the fix is transparency, not '
        'elimination.',
    readTime: '3 min',
    date: '2026-05-25',
  );

  static const regions = <(String, Story)>[
    ('The Americas', americas),
    ('Europe', europe),
    ('Asia-Pacific', lead),
    ('Middle East', middleEast),
    ('Africa', africa),
  ];

  static const ticker =
      'Ukraine President Zelenskyy fires Commander-in-Chief Syrskyi and '
      'appoints Major General Drapatyi following mass protests • Houthi rebels '
      'blockade Red Sea shipping to Saudi Arabia ports, forcing oil tankers to '
      'divert to Suez Canal • France passes law banning social media for '
      'children under age 15';

  /// Type specimen for the article body. Placeholder copy, not reporting.
  static const bodyHtml = '''
<p>Body copy is set in Source Serif 4 at 18.5pt with a 1.65 line height, the measure the website uses for its articles. Paragraphs are separated by space, not indents.</p>
<h3>Subheads are bold serif</h3>
<p>Inline styles such as <strong>bold for emphasis</strong> and <em>italic for titles</em> keep the body color, and <a href="https://theutahview.com">links are underlined in red</a>.</p>
<blockquote>Pull quotes are set in italic with a red rule on the left.</blockquote>
<ul><li>Bulleted lists keep the serif face.</li><li>Each item has a little breathing room.</li></ul>
<ol><li>Numbered lists work the same way.</li><li>Images below run full width with rounded corners.</li></ol>
<img src="/images/sample.jpg" alt="Sample photo">
<p>When a story ends, a small red square marks the end of the article.</p>
''';
}
