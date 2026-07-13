import fs from 'node:fs'
import path from 'node:path'

const migratedEnglishLiterals = [
  'Goal conversions',
  'No data yet',
  'Press / to search',
  'current visitors',
  'Total pageviews',
  'Views per visit',
  'Top sources',
  'Entry pages',
  'Exit pages'
]

const allowedTechnicalTerms = new Set([
  'API',
  'ClickHouse',
  'CSV',
  'GeoLite2',
  'MaxMind',
  'OS',
  'Plausible',
  'UTM'
])

function sourceFiles(directory: string): string[] {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const target = path.join(directory, entry.name)

    if (entry.isDirectory()) return sourceFiles(target)
    if (!/\.[jt]sx?$/.test(entry.name) || /\.test\.[jt]sx?$/.test(entry.name)) {
      return []
    }

    return [target]
  })
}

test('migrated customer-facing strings do not return as dashboard literals', () => {
  const failures = sourceFiles(path.join(__dirname, 'dashboard')).flatMap(
    (filename) => {
      const source = fs.readFileSync(filename, 'utf8')
      return migratedEnglishLiterals
        .filter((literal) => source.includes(literal))
        .map((literal) => `${path.relative(__dirname, filename)}: ${literal}`)
    }
  )

  expect(failures).toEqual([])
})

test('the technical-term allowlist is explicit and stable', () => {
  expect([...allowedTechnicalTerms].sort()).toEqual([
    'API',
    'CSV',
    'ClickHouse',
    'GeoLite2',
    'MaxMind',
    'OS',
    'Plausible',
    'UTM'
  ])
})
