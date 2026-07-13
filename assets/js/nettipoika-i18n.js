const finnish = {
  'Account settings': 'Tilin asetukset',
  'Add a website': 'Lisää verkkosivusto',
  'Add custom property': 'Lisää mukautettu ominaisuus',
  'Add goal': 'Lisää tavoite',
  All: 'Kaikki',
  'All visitors': 'Kaikki kävijät',
  'API keys': 'API-avaimet',
  'Apply filter': 'Käytä suodatinta',
  Audience: 'Yleisö',
  Back: 'Takaisin',
  'Bounce rate': 'Välitön poistuminen',
  Browser: 'Selain',
  Browsers: 'Selaimet',
  Cancel: 'Peruuta',
  'Change domain': 'Vaihda verkkotunnus',
  'Choose a site': 'Valitse sivusto',
  City: 'Kaupunki',
  Compare: 'Vertaa',
  Conversions: 'Konversiot',
  Countries: 'Maat',
  Country: 'Maa',
  'Create a team': 'Luo tiimi',
  'Create site': 'Luo sivusto',
  'Current visitors': 'Kävijöitä nyt',
  'Custom event': 'Mukautettu tapahtuma',
  'Custom events': 'Mukautetut tapahtumat',
  'Custom properties': 'Mukautetut ominaisuudet',
  Dashboard: 'Tilastonäkymä',
  'Danger zone': 'Vaaravyöhyke',
  'Date range': 'Aikaväli',
  Day: 'Päivä',
  Delete: 'Poista',
  Device: 'Laite',
  Devices: 'Laitteet',
  'Direct / None': 'Suora / Ei lähdettä',
  Domain: 'Verkkotunnus',
  Download: 'Lataa',
  Edit: 'Muokkaa',
  Email: 'Sähköposti',
  'Email reports': 'Sähköpostiraportit',
  'Engagement rate': 'Sitoutumisaste',
  'Entry pages': 'Saapumissivut',
  'Event conversions': 'Tapahtumakonversiot',
  'Event name': 'Tapahtuman nimi',
  'Exit pages': 'Poistumissivut',
  Export: 'Vie tiedot',
  Filter: 'Suodata',
  Filters: 'Suodattimet',
  'First visit': 'Ensimmäinen käynti',
  'Form submissions': 'Lomakkeiden lähetykset',
  General: 'Yleiset',
  Goals: 'Tavoitteet',
  'Help center': 'Ohjekeskus',
  Hostnames: 'Isäntänimet',
  Import: 'Tuo tiedot',
  'Imports & exports': 'Tuonti ja vienti',
  Installation: 'Asennus',
  Integrations: 'Integraatiot',
  'Invite team members': 'Kutsu tiimin jäseniä',
  'IP addresses': 'IP-osoitteet',
  'Last 12 months': 'Viimeiset 12 kuukautta',
  'Last 28 days': 'Viimeiset 28 päivää',
  'Last 30 days': 'Viimeiset 30 päivää',
  'Last 6 months': 'Viimeiset 6 kuukautta',
  'Last 7 days': 'Viimeiset 7 päivää',
  'Last month': 'Viime kuukausi',
  'Last week': 'Viime viikko',
  'Learn more': 'Lue lisää',
  Locations: 'Sijainnit',
  'Log out': 'Kirjaudu ulos',
  Login: 'Kirjaudu',
  Members: 'Jäsenet',
  Month: 'Kuukausi',
  More: 'Lisää',
  Name: 'Nimi',
  'New site': 'Uusi sivusto',
  'No results': 'Ei tuloksia',
  'Operating system': 'Käyttöjärjestelmä',
  'Operating systems': 'Käyttöjärjestelmät',
  'Outbound links': 'Lähtevät linkit',
  Page: 'Sivu',
  'Page path': 'Sivupolku',
  Pageviews: 'Sivulataukset',
  Pages: 'Sivut',
  Password: 'Salasana',
  People: 'Käyttäjät',
  Preferences: 'Asetukset',
  'Previous period': 'Edellinen ajanjakso',
  Properties: 'Ominaisuudet',
  'Public dashboard': 'Julkinen tilastonäkymä',
  Realtime: 'Reaaliaikainen',
  Referrer: 'Viittaaja',
  Referrers: 'Viittaajat',
  Region: 'Alue',
  Register: 'Rekisteröidy',
  Remove: 'Poista',
  Revenue: 'Liikevaihto',
  Save: 'Tallenna',
  'Save changes': 'Tallenna muutokset',
  'Screen size': 'Näytön koko',
  Search: 'Hae',
  Security: 'Tietoturva',
  Segments: 'Segmentit',
  'Select date range': 'Valitse aikaväli',
  Settings: 'Asetukset',
  Shields: 'Suojaukset',
  'Sign up': 'Rekisteröidy',
  'Signed in as': 'Kirjautuneena',
  Site: 'Sivusto',
  'Site settings': 'Sivuston asetukset',
  Sites: 'Sivustot',
  Source: 'Lähde',
  Sources: 'Liikenteen lähteet',
  'Stats API': 'Tilasto-API',
  Team: 'Tiimi',
  'Team settings': 'Tiimin asetukset',
  'This month': 'Tämä kuukausi',
  'This week': 'Tämä viikko',
  Today: 'Tänään',
  'Top pages': 'Suosituimmat sivut',
  'Top sources': 'Tärkeimmät liikenteen lähteet',
  'Total visits': 'Käynnit yhteensä',
  'Unique visitors': 'Yksilölliset kävijät',
  Upgrade: 'Päivitä tilaus',
  'Verify installation': 'Tarkista asennus',
  Visibility: 'Näkyvyys',
  Visitor: 'Kävijä',
  Visitors: 'Kävijät',
  'Visit duration': 'Käynnin kesto',
  Visits: 'Käynnit',
  Week: 'Viikko',
  'Welcome to Plausible!': 'Tervetuloa Nettipoika Kävijäseurantaan!',
  Year: 'Vuosi',
  Yesterday: 'Eilen',
  'Your sites': 'Sivustosi'
}

const attributes = ['aria-label', 'placeholder', 'title']

function locale() {
  return document.documentElement.dataset.locale || 'fi'
}

function translateValue(value) {
  if (locale() !== 'fi' || !value) return value
  const trimmed = value.trim()
  return finnish[trimmed] || value
}

function translateTextNode(node) {
  if (!node.nodeValue || node.parentElement?.closest('[data-no-translate]'))
    return
  const translated = translateValue(node.nodeValue)
  if (translated !== node.nodeValue) {
    const leading = node.nodeValue.match(/^\s*/)?.[0] || ''
    const trailing = node.nodeValue.match(/\s*$/)?.[0] || ''
    node.nodeValue = leading + translated.trim() + trailing
  }
}

function translateElement(element) {
  if (!(element instanceof Element) || element.closest('[data-no-translate]'))
    return

  for (const attribute of attributes) {
    if (element.hasAttribute(attribute)) {
      const value = element.getAttribute(attribute)
      const translated = translateValue(value)
      if (translated !== value) element.setAttribute(attribute, translated)
    }
  }

  for (const child of element.childNodes) {
    if (child.nodeType === Node.TEXT_NODE) translateTextNode(child)
  }

  for (const child of element.children) translateElement(child)
}

export function initNettipoikaLocalization() {
  if (locale() !== 'fi') return

  translateElement(document.body)

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      if (mutation.type === 'characterData') translateTextNode(mutation.target)
      for (const node of mutation.addedNodes) {
        if (node.nodeType === Node.TEXT_NODE) translateTextNode(node)
        if (node.nodeType === Node.ELEMENT_NODE) translateElement(node)
      }
    }
  })

  observer.observe(document.body, {
    characterData: true,
    childList: true,
    subtree: true
  })
}

export { finnish }
