# Python

An instance of [the toolchain contract](CONTRACT.md). Grades are from `register.json`; re-read
it, since this page does not track it.

## Detection

`pyproject.toml`, `setup.py`, `setup.cfg`, `requirements*.txt`, `Pipfile`, `uv.lock`,
`poetry.lock`, `tox.ini`, `noxfile.py`, or tracked `*.py` files. Run every command below with the
project's own interpreter (its virtual environment, `uv run`, `poetry run` or `hatch run`), not
the system one.

## Entry point

Whatever CI runs: commonly `make check`, `tox`, `nox`, `pre-commit run --all-files`, a
`scripts/qa/` runner or a `[tool.*]` task in `pyproject.toml`. Ruff, mypy, Pyright and Pylint
are often run separately in CI; if so, record each command, since the entry point is then their
sequence.

## Rule host

| Host                                 | Register grade (detector) | Use it for                                                                         |
| ------------------------------------ | ------------------------- | ---------------------------------------------------------------------------------- |
| An existing rule or ban list         | As its detector           | A class a bundled rule already detects, or a banned import or attribute            |
| Pylint custom checker                | Green                     | Any class expressible over the syntax tree, with Pylint's inference where needed   |
| Semgrep                              | Amber                     | Pattern-shaped classes, and classes that span Python and other languages           |
| An abstract-syntax-tree check script | Ungraded, project-built   | Classes needing project knowledge no generic host has, such as a list of constants |
| Flake8 plugin                        | Amber                     | Projects that already run Flake8 and write plugins for it                          |
| Ruff, mypy, Pyright (bespoke rules)  | Red                       | Nothing bespoke: none can host a project's own rule. Keep running them as checks   |

**An existing rule** comes first where it genuinely detects the class, as the contract's
[rule host](CONTRACT.md#rule-host) section says: Pylint's `unspecified-encoding`, say, already
detects text-mode `open()` without an encoding. Ruff's `flake8-tidy-imports.banned-api` setting
attaches a message to the bundled `TID251` to ban an import or an attribute; every such ban
prints `TID251`, so the message carries the project's identifier, and Ruff's red grade on
detector clause 4.1 is a gap to record.

**Pylint.** Write a checker class deriving from `pylint.checkers.BaseChecker` whose `msgs` maps a
message id to its text, symbol and description; put the correct construction, or the path of the
rule's page, in the description. Load it with `load-plugins` under `[tool.pylint.main]` in
`pyproject.toml`, or in `.pylintrc`.

**Check script.** A script over Python's own `ast` module sees the syntax a text search cannot,
without a third-party host; it is the last resort the contract's
[check scripts](CONTRACT.md#check-scripts) section describes, and must offer everything listed
there. The shape, for an illustrative class that an existing Pylint rule would in practice
already cover:

```python
import ast
import sys
from pathlib import Path

RULE = "PROJ001"
SUMMARY = "text-mode open() must name its encoding"
PAGE = f"docs/rules/{RULE}.md"


def is_unencoded_text_open(call: ast.Call) -> bool:
    if not (isinstance(call.func, ast.Name) and call.func.id == "open"):
        return False
    if len(call.args) >= 4 or any(k.arg == "encoding" for k in call.keywords):
        return False
    mode = call.args[1] if len(call.args) >= 2 else None
    for keyword in call.keywords:
        if keyword.arg == "mode":
            mode = keyword.value
    binary = (
        isinstance(mode, ast.Constant)
        and isinstance(mode.value, str)
        and "b" in mode.value
    )
    return not binary


def main(argv: list[str]) -> int:
    if argv == ["--list"]:
        print(f"{RULE}  {SUMMARY}  {PAGE}")
        return 0
    found = False
    for arg in argv:
        try:
            tree = ast.parse(Path(arg).read_text(encoding="utf-8"), filename=arg)
        except SyntaxError as error:
            print(f"{arg}:{error.lineno}: cannot parse: {error.msg}", file=sys.stderr)
            return 2
        except (OSError, UnicodeDecodeError) as error:
            print(f"{arg}: cannot read: {error}", file=sys.stderr)
            return 2
        for node in ast.walk(tree):
            if isinstance(node, ast.Call) and is_unencoded_text_open(node):
                print(f"{arg}:{node.lineno}: {RULE} {SUMMARY}; see {PAGE}")
                found = True
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
```

It reports a finding with exit 1, fails with exit 2 on a file it cannot read or parse, and
lists its rule with `--list`. A mode computed at run time is reported rather than guessed at, because
narrowing where you are unsure is the owner's decision. A script parses syntax and does not know
types; a class that depends on what a name refers to belongs in Pylint, which infers.

## Harness and proof

- Pylint: `pylint --load-plugins=<module> --disable=all --enable=<symbol> <file>`. Keep the
  fixture test as a `pylint.testutils.CheckerTestCase` in the project's pytest suite.
- Semgrep: `semgrep scan --no-rewrite-rule-ids --config <rule-file> --error <file>`, and
  `semgrep scan --test <rules-dir>` for its fixtures.
- Check script: `python <script> <file>`, and a pytest test that runs it on a fixture that must
  fire and one that must stay silent, asserting the exit code and the printed identifier.

## Identifier and page

A Pylint message prints its symbol and id with every finding, and
`pylint --load-plugins=<module> --help-msg=<symbol>` prints its description offline. Semgrep and a
check script print what the message carries, so the message starts with the identifier and names
the page. The page goes where the contract's [identifier and page](CONTRACT.md#identifier-and-page)
section says.

## Sweep

Every first-party package and script directory, tests included where the pattern can occur in
them. Exclude the virtual environment (`.venv`, `venv`), `build/`, `dist/`, `*.egg-info`,
`site-packages`, generated modules such as `*_pb2.py`, and generated migrations. Count the files
with `git ls-files '*.py'` and compare with what the tool scanned. Semgrep skips `tests/` by
default, as the contract's [Semgrep section](CONTRACT.md#semgrep-as-the-fallback) says, and a
Python script with no `.py` extension in `bin/` needs naming explicitly to a check script.

## Listing and project record

`pylint --list-msgs-enabled` lists what Pylint will run, including loaded plugins; Ruff's
`ruff check --show-settings` prints its resolved configuration. Neither lists Semgrep rules or
check scripts, so a project that mixes hosts has no single listing unless it built one; report
that against toolchain section [5](../spec/TOOLING-SPEC.md#5-enumeration). Exceptions commonly
live in `pyproject.toml` (`per-file-ignores`, `[tool.pylint]` disables, mypy overrides); a TOML
comment beside the entry is the usual justification, and no Python tool rejects a missing one.

## Suppression routes

| Route                        | Tool         | What closes it                                                                      |
| ---------------------------- | ------------ | ----------------------------------------------------------------------------------- |
| `# noqa`, `# noqa: <code>`   | Ruff, Flake8 | `ruff check --ignore-noqa`; `flake8 --disable-noqa`                                 |
| `# pylint: disable=<symbol>` | Pylint       | Enabling `locally-disabled` and `suppressed-message` and naming them in `--fail-on` |
| `# type: ignore`             | mypy         | A rule of the project's own                                                         |
| `# type: ignore`             | Pyright      | `enableTypeIgnoreComments = false` under `[tool.pyright]`                           |
| `# pyright: ignore`          | Pyright      | A rule of the project's own                                                         |
| `# nosec`                    | Bandit       | `bandit --ignore-nosec`                                                             |
| `# nosemgrep`                | Semgrep      | `semgrep scan --disable-nosem`                                                      |

A rule of the project's own for comment forms is a Semgrep `pattern-regex` rule or a line check
in a script. Whether to close a route on a tool the project already runs is the owner's
decision, as the contract's [suppression routes](CONTRACT.md#listing-project-record-and-suppression-routes)
paragraph says.

## Runner

pytest, or `unittest` where the project uses it. The reproducing test for the original defect
goes in the project's existing suite.

## CI hook

`.github/workflows/`, `.gitlab-ci.yml`, `tox.ini` and `noxfile.py` environments, and
`.pre-commit-config.yaml`. Record which of the commands above each runs.

## Known gaps

- Ruff, mypy and Pyright cannot host a bespoke rule, and mypy's and Pyright's codes resolve
  online only.
- Pylint is the only Python detector the register grades green; Flake8 and Bandit resolve none of
  their identifiers offline.
