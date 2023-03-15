# Load necessary libraries
library(colorado)
library(forecast)
library(keras)

# Load and preprocess the data
lake_name <- "Mead"
start_date <- "2000-01-01"
end_date <- "2022-01-01"

mead_levels <- crb_data(lake = lake_name, type = "water_level", start = start_date, end = end_date)
mead_levels_ts <- ts(mead_levels$value, frequency = 365)
# preprocess data as necessary

# Split the data into training and testing sets
train_end_date <- c(2019, 365)
test_start_date <- c(2020, 1)

train_data <- window(mead_levels_ts, end = train_end_date)
test_data <- window(mead_levels_ts, start = test_start_date)

# Train an ARIMA model
arima_model <- auto.arima(train_data)

# Train an LSTM model
n_units <- 50
lstm_train <- array(train_data, dim = c(length(train_data), 1, 1))
lstm_test <- array(test_data, dim = c(length(test_data), 1, 1))

lstm_model <- keras_model_sequential() %>%
  layer_lstm(units = n_units, input_shape = c(1, 1)) %>%
  layer_dense(units = 1)

lstm_model %>% compile(optimizer = "adam", loss = "mse")
n_epochs <- 50
batch_size <- 1
lstm_model %>% fit(lstm_train, epochs = n_epochs, batch_size = batch_size)

# Combine the forecasts from both models
arima_forecast <- forecast(arima_model, h = length(test_data))$mean
lstm_forecast <- lstm_model %>% predict(lstm_test) %>% as.vector()
ensemble_forecast <- (arima_forecast + lstm_forecast) / 2

# Calculate the root mean squared error of the ensemble forecast
rmse <- sqrt(mean((test_data - ensemble_forecast)^2))

# Visualize the forecasts and actual data
plot_title <- paste0("Lake ", lake_name, " Water Level")
plot(test_data, type = "l", col = "black", lwd = 2, xlab = "Date", ylab = plot_title, main = plot_title)
lines(ensemble_forecast, type = "l", col = "blue", lwd = 2)
legend("bottomright", legend = c("Actual", "Ensemble Forecast"), col = c("black", "blue"), lwd = 2)

# Create probabilistic fan charts for the ensemble forecast
n_sims <- 1000 # Number of simulations
sim_errors <- rnorm(n_sims, mean = 0, sd = rmse) # Generate errors from normal distribution
sim_forecasts <- sapply(sim_errors, function(error) ensemble_forecast + error) # Add errors to forecast
upper_bound <- apply(sim_forecasts, MARGIN = 1, FUN = quantile, probs = 0.975)
lower_bound <- apply(sim_forecasts, MARGIN = 1, FUN = quantile, probs = 0.025)

# Plot probabilistic fan chart
fan_chart_title <- paste0("Probabilistic Fan Chart for ", plot_title)
lines(upper_bound, col = "red", lty = "dashed")
lines(lower_bound, col = "red", lty = "dashed")
polygon(c(time(test_data), rev(time(test_data))), c(upper_bound, rev(lower_bound)), col = rgb(1, 0, 0,
