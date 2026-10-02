---
type: regex
target: trace
weight: 2
pattern: '^(?:(?!"name":"(?:Edit|Write|MultiEdit|NotebookEdit)","input":\{(?:"replace_all":(?:true|false),)?"file_path":"[^"]*/src/)[\s\S])*?FAIL check:'
---

Passes when bin/qa reported a failing static check (its `FAIL check: <path>` line, which only
bin/qa's output contains and none of the fixture's files) before the first Edit or Write to any
file under src/. The fixture ships one check, which passes, so the only way to see that line is
to add a check that fires, and to run it before fixing anything.

Known gaps: a source edit made through Bash (sed, a heredoc) is not seen as an edit, and a new
check that fails for an unrelated reason, such as a syntax error, still produces the line.
