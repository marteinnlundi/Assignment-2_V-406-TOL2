# ----- 0) Libraries -----
need <- c("ggplot2","dplyr","tidyr","readxl","lmtest","tseries","broom","janitor","skimr")
miss <- setdiff(need, rownames(installed.packages()))
if (length(miss)) install.packages(miss, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(tidyr); library(readxl)
  library(lmtest); library(tseries); library(broom); library(janitor); library(skimr)
})

# ----- 0b) Paths & timestamp -----
ts <- format(Sys.time(), "%Y%m%d-%H%M%S")
out_dir <- "outputs"
fig_dir <- file.path(out_dir, "figs")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# helpers for file naming
FN  <- function(stem, ext) file.path(out_dir, paste0(stem, "_", ts, ".", ext))
FNF <- function(stem, ext) file.path(fig_dir, paste0(stem, "_", ts, ".", ext))

# ----- 1) Import -----
wide <- read_excel("as2_wideData_group6.xlsx") |> clean_names()
long <- read_excel("as2_longData_group6.xlsx") |> clean_names()

# basic structure and summary check
capture.output({
  cat("=== WIDE DATA ===\n")
  print(skim(wide))
  cat("\n=== LONG DATA ===\n")
  print(skim(long))
}, file = FN("01_skim_data", "txt"))

# ----- 2) Plot all indices (Task 1) -----

# Line chart of sales, purchase_power, and consumer_sentiment
g1 <- ggplot(long, aes(x = time, y = value, color = name)) +
  geom_line(linewidth = 0.8) +
  labs(title = "Sales, Purchase Power, and Consumer Sentiment Over Time",
       x = "Time (Months)", y = "Index Value", color = "Index") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

ggsave(FNF("02_line_all_indices", "png"), g1, width = 7, height = 5, dpi = 300)

# short note file for observations
capture.output({
  cat("=== Task 1: Line Plot Observations ===\n")
  cat("Plot shows overall trends in the three indexes over 10 years.\n")
  cat("Comment on visible lead/lag relationships based on plot inspection.\n")
}, file = FN("02_plot_notes", "txt"))


# ----- 3) Regression (Task 2) -----
# TODO:
#   • lm(sales ~ time, data = wide)
#   • save summary() output
#   • add residuals column: resid(model)
#   • plot residuals vs time (geom_line)
#   • save plot

# Simple regression model: sales ~ time
m_time <- lm(sales ~ time, data = wide)

# Save regression summary to file
capture.output(summary(m_time), file = FN("03_regression_sales_time_summary", "txt"))

# Add residuals to data
wide <- wide |> mutate(resid_time = resid(m_time))

# Plot residuals over time
g2 <- ggplot(wide, aes(x = time, y = resid_time)) +
  geom_line(linewidth = 0.8, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(title = "Residuals from Regression of Sales on Time",
       x = "Time (Months)", y = "Residuals") +
  theme_minimal(base_size = 11)


ggsave(FNF("03_residuals_over_time", "png"), g2, width = 7, height = 5, dpi = 300)

# Short text summary

# ----- 4) Residual tests -----
# TODO:
#   • dwtest(model)
#   • adf.test(resid(model))
#   • record both outputs to text file
#   • note interpretation (autocorr / stationarity)

# ----- 5) Granger causality (Task 3) -----
# TODO:
#   • grangertest(sales ~ purchase_power, order = 3, data = wide)
#   • grangertest(sales ~ consumer_sentiment, order = 3, data = wide)
#   • grangertest(purchase_power ~ consumer_sentiment, order = 3, data = wide)
#   • save all results to one text file
#   • flag any p < 0.05 as evidence of causality


# ----- 6) Summary output -----

summary_notes <- tibble(
  task = c("Task 1 — Time-Series Plot", "Task 2 — Regression of Sales on Time"),
  description = c(
    "Visual comparison of sales, purchase_power, and consumer_sentiment over time",
    "Linear regression of sales on time with residual analysis"
  ),
  figure = c(
    FNF("02_line_all_indices", "png"),
    FNF("03_residuals_over_time", "png")
  ),
  key_points = c(
    "All three indexes show similar long-run movement; possible short lead of purchase_power before sales",
    "Regression shows an upward trend in sales over time; residuals fluctuate around zero, indicating a reasonable fit"
  )
)

write.csv(summary_notes, FN("06_summary_tasks", "csv"), row.names = FALSE)

capture.output({
  cat("=== Summary of Tasks ===\n\n")
  cat("Task 1 — Time-Series Plot:\n")
  cat("• All indexes trend upward over the 10-year period.\n")
  cat("• Purchase power and consumer sentiment show mild lead behavior relative to sales.\n\n")
  cat("Task 2 — Regression of Sales on Time:\n")
  cat("• Estimated a simple linear trend: sales ~ time.\n")
  cat("• Model summary and residual plot saved to outputs/figs.\n")
  cat("• Residuals show no strong pattern; next step is to formally test for autocorrelation and stationarity.\n")
}, file = FN("06_summary_tasks_notes", "txt"))


# ----- 99) Session info -----
capture.output(sessionInfo(), file = FN("99_sessionInfo", "txt"))
