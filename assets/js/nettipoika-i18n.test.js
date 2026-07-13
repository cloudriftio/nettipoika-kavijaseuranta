import { finnish, initNettipoikaLocalization } from './nettipoika-i18n'

describe('Nettipoika localization', () => {
  beforeEach(() => {
    document.documentElement.dataset.locale = 'fi'
    document.body.innerHTML =
      '<button aria-label="Save">Save</button><input placeholder="Search">'
  })

  test('translates server-rendered text and attributes', () => {
    initNettipoikaLocalization()

    expect(document.querySelector('button')).toHaveTextContent('Tallenna')
    expect(document.querySelector('button')).toHaveAttribute(
      'aria-label',
      'Tallenna'
    )
    expect(document.querySelector('input')).toHaveAttribute(
      'placeholder',
      'Hae'
    )
  })

  test('contains translations for the primary customer navigation', () => {
    for (const key of [
      'Visitors',
      'Pageviews',
      'Sources',
      'Pages',
      'Settings',
      'Log out'
    ]) {
      expect(finnish[key]).toBeTruthy()
    }
  })
})
