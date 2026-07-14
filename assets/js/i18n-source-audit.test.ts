import fs from 'node:fs'
import path from 'node:path'
import * as ts from 'typescript'
import { englishCatalog } from './i18n'

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

const allowedDataAndProtocolLiterals = new Set([
  'Direct / None',
  'OS',
  'URL',
  'contains',
  'does not contain',
  'is',
  'is not'
])

function isTranslationKey(node: ts.StringLiteralLike): boolean {
  const call = node.parent
  return (
    ts.isCallExpression(call) &&
    ts.isIdentifier(call.expression) &&
    ['t', 'tn'].includes(call.expression.text)
  )
}

test('customer-facing dashboard catalog strings are referenced through i18n', () => {
  const catalogValues: Set<string> = new Set(
    Object.values(englishCatalog).filter(
      (value) =>
        !value.includes('{{') && !allowedDataAndProtocolLiterals.has(value)
    )
  )

  const failures = sourceFiles(path.join(__dirname, 'dashboard')).flatMap(
    (filename) => {
      const source = fs.readFileSync(filename, 'utf8')
      const sourceFile = ts.createSourceFile(
        filename,
        source,
        ts.ScriptTarget.Latest,
        true,
        filename.endsWith('x') ? ts.ScriptKind.TSX : ts.ScriptKind.TS
      )
      const literals: Array<{ text: string; position: number }> = []

      const visit = (node: ts.Node) => {
        if (
          (ts.isStringLiteral(node) ||
            ts.isNoSubstitutionTemplateLiteral(node)) &&
          catalogValues.has(node.text) &&
          !isTranslationKey(node)
        ) {
          literals.push({
            text: node.text,
            position: node.getStart(sourceFile)
          })
        }
        if (ts.isJsxText(node)) {
          const text = node.getText(sourceFile).trim()
          if (catalogValues.has(text)) {
            literals.push({ text, position: node.getStart(sourceFile) })
          }
        }
        ts.forEachChild(node, visit)
      }
      visit(sourceFile)

      return literals.map(({ text, position }) => {
        const { line } = sourceFile.getLineAndCharacterOfPosition(position)
        return `${path.relative(__dirname, filename)}:${line + 1}: ${text}`
      })
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
