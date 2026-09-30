# checkout-pricing

Prices order lines and carts for the checkout.

## QA

`bin/qa` is the only entry point, locally and in CI. It runs the type check (`tsc`), every
static check in `qa/checks/`, and the tests (`node --test`). `bin/qa --list` lists the static
checks without running them.

A static check is an executable file in `qa/checks/` with an `# id:` and a `# summary:` header
line. It exits non-zero and prints its id when it finds a violation. Each id is documented
below.

## Checks

### QA001

No `console.log` in `src/`. Use the logger.
