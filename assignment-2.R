# ----- 0) Libraries -----
# TODO: load or install these:
#   ggplot2, dplyr, tidyr, readxl, lmtest, tseries, broom, janitor

# ----- 1) Import -----
# TODO:
#   • read both Excel files (wide + long)
#   • clean_names() on both
#   • check structure (skim() or glimpse())

# ----- 2) Plot all indices (Task 1) -----
# TODO:
#   • use ggplot(long, aes(x = time, y = value, color = name)) + geom_line()
#   • label axes + legend
#   • save to figs folder
#   • comment: any visible lead/lag?

# ----- 3) Regression (Task 2) -----
# TODO:
#   • lm(sales ~ time, data = wide)
#   • save summary() output
#   • add residuals column: resid(model)
#   • plot residuals vs time (geom_line)
#   • save plot

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
# TODO:
#   • small tibble with DW p, ADF p, Granger p-values
#   • write.csv() to outputs folder
#   • short notes file explaining findings

# ----- 99) Session info -----
# TODO: capture.output(sessionInfo(), file = "outputs/99_sessionInfo.txt")
