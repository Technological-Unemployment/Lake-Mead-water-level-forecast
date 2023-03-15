# Lake Mead Water Level Forecast
This R code provides an example of how to forecast the water level of Lake Mead using two different models, ARIMA and LSTM, and then combining their forecasts using an ensemble method. It also creates a probabilistic fan chart to visualize the uncertainty in the forecast.

## Data
The data used in this project is the water level of Lake Mead, which is obtained using the crb_data function from the colorado library. The data spans from January 1st, 2000 to January 1st, 2022, and is split into a training set and a testing set.

## Models
Two models are used to forecast the water level: ARIMA and LSTM. The ARIMA model is trained on the training set using the auto.arima function from the forecast library. The LSTM model is trained using the keras library.

## Ensemble Forecast
The forecasts from the ARIMA and LSTM models are combined using an ensemble method. The root mean squared error of the ensemble forecast is calculated and used to generate a probabilistic fan chart to visualize the uncertainty in the forecast.

## Dependencies
This code requires installing the following R packages: colorado, forecast, and keras.

## Running the Code
To run this code, simply copy and paste it into an R script editor and run the script. Note that the colorado, forecast, and keras libraries must be installed in your R environment beforehand. Additionally, you may need to adjust the file path and file name in the dev.copy function to save the fan chart to the desired location on your machine.
