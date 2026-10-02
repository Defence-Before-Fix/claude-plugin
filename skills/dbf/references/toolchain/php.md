# PHP

An instance of [the toolchain contract](CONTRACT.md). Grades are from `register.json`; re-read
it, since this page does not track it. The reference toolchain is php-qa-ci, and its register
page, `tools/php-qa-ci.md` at the path the refresh script prints (vendored at
[spec/tools/php-qa-ci.md](../spec/tools/php-qa-ci.md)), is the verified source for every
php-qa-ci command below.

## Detection

`composer.json`, `composer.lock`, or tracked `*.php` files. php-qa-ci is present when
`composer.json` requires it and its `qa` command exists, at `bin/qa` as the register page names
it or in the project's Composer bin directory. The manifest declaration, if the project made
one, is `extra.defence-before-fix` in `composer.json`, with its gaps under `known-gaps`.

## Entry point

With php-qa-ci, `bin/qa`, which runs coding standards, linting, static analysis and then tests,
and takes `-t <tool>` and `-p <path>` to narrow. Without it, whatever CI runs: commonly
`composer run` scripts wrapping `vendor/bin/phpstan analyse` and `vendor/bin/phpunit`.

## Rule host

| Host                         | Register grade (detector) | Use it for                                                           |
| ---------------------------- | ------------------------- | -------------------------------------------------------------------- |
| An existing PHPStan rule     | Amber                     | A class a bundled or installed rule already detects                  |
| A PHPStan custom rule        | Amber                     | Any class over syntax and types; the host php-qa-ci wraps            |
| A PHP_CodeSniffer sniff      | Amber                     | Token-level and layout classes, in projects that already run PHPCS   |
| Psalm plugin                 | Amber                     | Projects that run Psalm rather than PHPStan                          |
| Semgrep                      | Amber                     | Pattern-shaped classes, and classes spanning PHP and other languages |
| PHPArkitect, Deptrac, Rector | Red                       | Nothing routed as a defence; keep running them as checks             |

A PHPStan rule implements `PHPStan\Rules\Rule`, builds each error with `RuleErrorBuilder` and
gives it an `->identifier(...)`, and is registered under `rules:` in the PHPStan configuration.
With php-qa-ci, that configuration is `qaConfig/phpstan.neon` and the identifier follows the
bundle's `phpqaci`-style constant.

## Harness and proof

- php-qa-ci: `bin/phpstan-rule <identifier> <path>` runs the one rule on the path.
- Bare PHPStan: a PHPUnit test extending `PHPStan\Testing\RuleTestCase`, whose `analyse()` call
  names a fixture file and the line and message expected on it.
- Keep fixtures out of the paths `phpstan.neon` analyses, or exclude them there.

## Identifier and page

PHPStan prints the identifier beneath each error. php-qa-ci's `bin/rule-doc <identifier>`
resolves it offline from `docs/phpstan-rules/`. Put the new rule's page there, then check
`bin/rule-doc` resolves the identifier exactly as printed, since the lookup may need more than
the page itself. Bare PHPStan resolves its own identifiers online only, so the message names the
project's page.

## Sweep

php-qa-ci: `bin/qa -t phpstan`, over the paths its configuration declares. Bare PHPStan:
`vendor/bin/phpstan analyse` over every first-party path, `tests/` included where the pattern can
occur. Exclude `vendor/`, generated proxies and caches (`var/cache/`, `generated/`) and the rule's
fixtures.

## Listing and project record

php-qa-ci: `bin/rules .` lists every active defence and the justified exceptions; run it first on
any project you arrive at. Its record is the `ignoreErrors` block of `qaConfig/phpstan.neon`, and
`bin/qa -t pij` rejects an entry without a specific justification. Without php-qa-ci there is no
derived listing; report the gap against toolchain section
[5](../spec/TOOLING-SPEC.md#5-enumeration).

## Suppression routes

| Route                                                                  | Tool            | What closes it                                                                     |
| ---------------------------------------------------------------------- | --------------- | ---------------------------------------------------------------------------------- |
| `@phpstan-ignore`, `@phpstan-ignore-next-line`, `@phpstan-ignore-line` | PHPStan         | php-qa-ci's `ForbidInlinePhpstanIgnoreRule`; otherwise a rule of the project's own |
| A generated `phpstan-baseline.neon`                                    | PHPStan         | Baseline entries kept in the configuration the record lives in                     |
| `@psalm-suppress`                                                      | Psalm           | A rule of the project's own                                                        |
| `// phpcs:ignore`, `// phpcs:disable`                                  | PHP_CodeSniffer | A rule of the project's own                                                        |
| `phparkitect-baseline.json`                                            | PHPArkitect     | The file kept out of the repository                                                |

Moving a baseline's entries or removing a baseline file changes what is suppressed, which is the
owner's decision: report the route and what would close it, as the contract's
[suppression routes](CONTRACT.md#listing-project-record-and-suppression-routes) paragraph says.

## Runner

PHPUnit, or Pest where the project uses it. php-qa-ci runs it last, after the detectors.

## CI hook

`.github/workflows/`, `.gitlab-ci.yml`, `composer.json` scripts and php-qa-ci's `ci.bash`, which
runs `bin/qa`.

## Known gaps

The register page lists php-qa-ci's recorded gaps: the PHPArkitect tier and some lanes print no
identifier, fifteen bundled rules had no page when it was checked, and two baseline routes stay
open. Report any that bear on the rule you wrote.
