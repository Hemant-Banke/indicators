# Moving Averages

### Aim :
1. To display Stock Indicators (Moving Averages, Volume)

### Instructions :
- Subscribe for Yahoo Finance API in RapdiAPI.
- Create a file `.Rprofile` in the directory containing
```RAPIDAPI_KEY = "<YOUR API KEY>" ```
- Run `main.R`

### Plot CandleStick Chart with Indicators
We first get the last one year price and volume data for the selected stock (AFFLE).
Then we find 50 day and 200 day trailing Moving Averages for this data.

Using Package **"Plotly"** we can then plot a candlestick chart with both moving averages and a volume subplot.

![Stock Chart](https://github.com/Hemant-Banke/indicators/blob/main/img/plot.png?raw=true)
