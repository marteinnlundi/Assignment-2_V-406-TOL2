# Assignment 2 – Group 6

This project analyzes simulated monthly data for **sales**, **purchase power**, and **consumer sentiment** to test whether changes in purchase power or consumer sentiment **Granger-cause sales**, and whether **purchase power Granger-causes consumer sentiment**, using three-lag regression comparisons and time-series diagnostics.

---

## Files

* `assignment-2.R` – full analysis script (**no console output**; all results saved to files)
* `as2_wideData_group6.xlsx` – main dataset in wide format (used for regressions)
* `as2_longData_group6.xlsx` – long-format dataset (used for plots)
* `outputs/` – folder automatically created with text/CSV results
* `outputs/figs/` – contains all generated figures (PNG format)

---

## Quick start

### Option 1 – Run in **RStudio**

1. Open the project folder in RStudio.
2. Ensure R is installed (and internet available for first-time package installs).
3. Make sure both Excel files are in the project root.
4. Run the script:

   ```r
   source("assignment-2.R")
   ```

---

### Option 2 – Run in **VS Code**

1. Open the folder in VS Code.
2. Install the **R extension** (`REditorSupport.r`) and ensure R is in your system PATH.
3. Open `assignment-2.R`.
4. Run the full script using:

   * **Ctrl + Shift + S** (Source file), or
   * Type in the VS Code R terminal:

     ```r
     source("assignment-2.R")
     ```

---

### Option 3 – Run in **Terminal**

If you prefer command-line execution:

```bash
Rscript assignment-2.R
```

All results will be written to:

* `outputs/` → CSV/TXT reports
* `outputs/figs/` → PNG plots

No output is printed in the terminal.

---

## Expected data structure

* **Wide data (`as2_wideData_group6.xlsx`):**
  Variables include
  `sales`, `purchase_power`, `consumer_sentiment`,
  their three lagged versions (`_lag1`, `_lag2`, `_lag3`),
  and identifiers (`time`, `month_num`, `year`).

* **Long data (`as2_longData_group6.xlsx`):**
  Columns `time`, `month_num`, `year`, `name`, `value`
  (used only for Task 1 plotting).

All variable names are cleaned to `snake_case` using `janitor::clean_names()`.

---

## Output summary

* **Task 1 – Time-Series Plot**
  Line chart comparing all three indices over time.

* **Task 2 – Regression and Diagnostics**
  Linear regression of sales on time; residual analysis with Durbin–Watson and ADF tests.

* **Task 3 – Granger Causality Tests**
  Three-lag comparisons testing whether

  1. `purchase_power` → `sales`
  2. `consumer_sentiment` → `sales`
  3. `purchase_power` → `consumer_sentiment`

All figures and result files are stored automatically — **no manual saving or console printing needed**.
