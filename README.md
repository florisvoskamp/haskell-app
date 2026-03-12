**Only this README was automatically generated with GitHub Copilot based on the codebase.**

---

# haskell-app

Haskell application containing recursion assignments and **BudgetFlow**: a small CLI for personal budget simulation, scenario comparison, and a Monte Carlo stress test.

## What the app does

- **Recursion exercises** (e.g. gcd, palindrome, digit sum, reverse list, binary print) are run when you start the app without arguments.
- **BudgetFlow** simulates a budget over several months from a TOML config:
  - **Baseline**: fixed monthly income and expenses, balance at the end of each month.
  - **Rules**: e.g. minimum balance; warnings are printed per month if they fail.
  - **Scenarios**: optional “what-if” (e.g. extra expenses from a given month), compared to the baseline.
  - **Monte Carlo**: many runs with random variable expenses; reports overdraft probability and percentile outcomes (p10/p50/p90).

All amounts in the config are in **cents**. The simulation core is pure; only config reading and printing use IO.

## How to run and test

**Prerequisites:** GHC and Cabal (e.g. `cabal build` works).

- **Default (no arguments)**  
  Runs recursion demos, then loads `test.toml` and runs baseline + default scenario + Monte Carlo report:
  ```bash
  cabal run
  ```

- **Subcommands** (pass arguments after `--`; specify the executable name so args go to the program):
  - **`run`** — only baseline simulation for the given config:
    ```bash
    cabal run haskell-app -- run test.toml
    ```
  - **`scenario`** — baseline + scenario comparison (config + scenario file):
    ```bash
    cabal run haskell-app -- scenario test.toml scenario.toml
    ```
  - **`stress`** — only Monte Carlo stress test:
    ```bash
    cabal run haskell-app -- stress test.toml
    ```

If you don’t pass any arguments, the app uses the default flow above (recursion + `test.toml` and all three BudgetFlow steps).

## Config and scenario files

**Main config** (e.g. `test.toml`):

- Top-level: `startBalance`, `monthsToSimulate` (amounts in cents).
- `[events]`: fixed monthly income/expenses, e.g. `Income = 200000`, `Rent = 100000`.
- `[rules]`: e.g. `MinBalance = 20000`.
- `[variable_expenses]`: for Monte Carlo, per category a range in cents, e.g. `Food = 30000 90000`.
- Optional **`[monte_carlo]`**: `runs = 1000`, `seed = 1` (defaults if omitted: 1000 runs, seed 1).

**Scenario file** (e.g. `scenario.toml`):

- `scenarioFrom = 2` — month from which the scenario events apply.
- `[events]`: extra or replacement events (same key/value style as in the main config), e.g. `Extra = 15000`.

## Launch configs (VS Code)

In **Run and Debug** you can use:

1. **BudgetFlow (default)** — runs `cabal run haskell-app --` (recursion + `test.toml` + baseline, scenario, stress).
2. **BudgetFlow (with args)** — runs `cabal run haskell-app -- stress test.toml`.
