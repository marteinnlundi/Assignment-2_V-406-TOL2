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

FN  <- function(stem, ext) file.path(out_dir, paste0(stem, "_", ts, ".", ext))
FNF <- function(stem, ext) file.path(fig_dir, paste0(stem, "_", ts, ".", ext))

# ----- 1) Import -----
wide <- read_excel("as2_wideData_group6.xlsx") |> clean_names()
long <- read_excel("as2_longData_group6.xlsx") |> clean_names()

capture.output({
  cat("=== WIDE DATA ===\n"); print(skim(wide))
  cat("\n=== LONG DATA ===\n"); print(skim(long))
}, file = FN("01_skim_data", "txt"))

# ----- 2) Plot all indices (Task 1) -----
g1 <- ggplot(long, aes(x = time, y = value, color = name)) +
  geom_line(linewidth = 0.8) +
  labs(title = "Sales, Purchase Power, and Consumer Sentiment Over Time",
       x = "Time (Months)", y = "Index Value", color = "Index") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

ggsave(FNF("02_line_all_indices", "png"), g1, width = 7, height = 5, dpi = 300)

# ----- 3) Regression (Task 2) -----
m_time <- lm(sales ~ time, data = wide)
capture.output(summary(m_time), file = FN("03_regression_sales_time_summary", "txt"))

wide <- wide |> mutate(resid_time = resid(m_time))

g2 <- ggplot(wide, aes(x = time, y = resid_time)) +
  geom_line(linewidth = 0.8, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(title = "Residuals from Regression of Sales on Time",
       x = "Time (Months)", y = "Residuals") +
  theme_minimal(base_size = 11)

ggsave(FNF("03_residuals_over_time", "png"), g2, width = 7, height = 5, dpi = 300)

# ----- 4) Residual tests -----
dw_out  <- lmtest::dwtest(m_time)
adf_out <- tseries::adf.test(wide$resid_time)

dw_pval  <- dw_out$p.value
adf_pval <- adf_out$p.value

capture.output({
  cat("=== Task 2: Residual Diagnostics Summary ===\n")
  cat("Durbin–Watson statistic:", round(dw_out$statistic, 3), "\n")
  cat("DW p-value:", round(dw_pval, 5), "\n")
  cat("ADF p-value:", round(adf_pval, 5), "\n")
}, file = FN("04_residual_diagnostics_summary", "txt"))

# ----- 5) Granger causality (Task 3) -----
# --- (a) purchase_power → sales ---
mod_sales_r <- lm(sales ~ sales_lag1 + sales_lag2 + sales_lag3, data = wide)
mod_sales_pp <- lm(sales ~ sales_lag1 + sales_lag2 + sales_lag3 +
                     purchase_power_lag1 + purchase_power_lag2 + purchase_power_lag3,
                   data = wide)
anova_sales_pp <- anova(mod_sales_r, mod_sales_pp)

# --- (b) consumer_sentiment → sales ---
mod_sales_cs <- lm(sales ~ sales_lag1 + sales_lag2 + sales_lag3 +
                     consumer_sentiment_lag1 + consumer_sentiment_lag2 + consumer_sentiment_lag3,
                   data = wide)
anova_sales_cs <- anova(mod_sales_r, mod_sales_cs)

# --- (c) consumer_sentiment → purchase_power ---
mod_pp_r <- lm(purchase_power ~ purchase_power_lag1 + purchase_power_lag2 + purchase_power_lag3,
               data = wide)
mod_pp_cs <- lm(purchase_power ~ purchase_power_lag1 + purchase_power_lag2 + purchase_power_lag3 +
                  consumer_sentiment_lag1 + consumer_sentiment_lag2 + consumer_sentiment_lag3,
                data = wide)
anova_pp_cs <- anova(mod_pp_r, mod_pp_cs)

# Save full ANOVA outputs
capture.output({
  cat("=== Task 3: Granger Causality Tests (Manual ANOVA) ===\n\n")
  cat("(a) purchase_power → sales\n"); print(anova_sales_pp)
  cat("\n---------------------------------------------\n")
  cat("(b) consumer_sentiment → sales\n"); print(anova_sales_cs)
  cat("\n---------------------------------------------\n")
  cat("(c) consumer_sentiment → purchase_power\n"); print(anova_pp_cs)
}, file = FN("05_granger_tests_full", "txt"))

# Compact summary table
granger_summary <- tibble(
  test = c("purchase_power → sales",
           "consumer_sentiment → sales",
           "consumer_sentiment → purchase_power"),
  p_value = c(anova_sales_pp$`Pr(>F)`[2],
              anova_sales_cs$`Pr(>F)`[2],
              anova_pp_cs$`Pr(>F)`[2])
)

write.csv(granger_summary, FN("05_granger_tests_summary", "csv"), row.names = FALSE)

# ----- 99) Session info -----
capture.output(sessionInfo(), file = FN("99_sessionInfo", "txt"))