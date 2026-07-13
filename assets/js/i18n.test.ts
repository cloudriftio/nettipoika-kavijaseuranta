import { currentLocale, englishCatalog, finnishCatalog, t, tn } from './i18n'

afterEach(() => {
  document.documentElement.lang = ''
  delete document.documentElement.dataset.locale
})

test('Finnish and English catalogs contain the same keys', () => {
  expect(Object.keys(finnishCatalog).sort()).toEqual(
    Object.keys(englishCatalog).sort()
  )
})

test('reads the server-provided locale and has a safe English test fallback', () => {
  expect(currentLocale()).toBe('en')

  document.documentElement.dataset.locale = 'fi'
  expect(currentLocale()).toBe('fi')

  document.documentElement.dataset.locale = 'en'
  expect(currentLocale()).toBe('en')
  expect(t('details')).toBe('Details')
})

test('interpolates values', () => {
  expect(t('lastUpdatedSecondsAgo', { seconds: 12 }, 'fi')).toBe(
    'Päivitetty 12 s sitten'
  )
})

test.each([
  [0, '0 kävijää juuri nyt'],
  [1, '1 kävijä juuri nyt'],
  [5, '5 kävijää juuri nyt']
])('selects the 0/1/n form for %i', (count, expected) => {
  expect(tn('currentVisitor', 'currentVisitors', count, {}, 'fi')).toBe(
    expected
  )
})
