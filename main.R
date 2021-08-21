# AIM :
# To display Stock Indicators (Moving Averages, Volume)

# Libraries (httr)
install.packages(c("httr", "jsonlite"))
library(httr)
library(jsonlite)

# Setup Environment
setwd("/media/hyena0/G Vol/rproj/Indicators")

# Get Stock Price Data through RapidAPI + Yahoo Finance API 
# Requires :
# symbol : Stock ticker as listed on Yahoo Finance
PriceData = function(symbol){
  url = sprintf("https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v3/get-historical-data?symbol=%s&region=IND", symbol)
  
  headers = add_headers(
    "x-rapidapi-key" = RAPIDAPI_KEY, 
    "x-rapidapi-host" = "apidojo-yahoo-finance-v1.p.rapidapi.com"
  )
  response = GET(url, headers)
  
  parsed = fromJSON(content(response, "text", encoding="UTF-8"), simplifyVector = FALSE)
  price_len = length(parsed$prices)
  
  data = matrix(0, nrow=252, ncol=6)
  colnames(data) = c("Date", "Open", "Close", "High", "Low", "Volume")
  data = data.frame(data)
  
  for (i in 1:252){
    price_list = parsed$prices[i][[1]]
    data_index = 252-i+1
    
    # Handle Null Price Data
    if (i > 0 && 
        (is.null(price_list$close) || 
         is.na(price_list$close))) {
      data[data_index,] = data[data_index+1,]
      next
    }
    data[data_index, "Date"] = as.numeric(price_list$date)
    data[data_index, "Open"] = as.numeric(price_list$open)
    data[data_index, "Close"] = as.numeric(price_list$close)
    data[data_index, "High"] = as.numeric(price_list$high)
    data[data_index, "Low"] = as.numeric(price_list$low)
    data[data_index, "Volume"] = as.numeric(price_list$volume)
  }
  
  data$Date = as.Date(as.POSIXct(as.numeric(data$Date), origin="1970-01-01"))
  
  return(data)
}

# Compute Moving Average
# Requires
# prices : Closing Prices of stock
# interval : No of days interval for moving average
# type : trail/central
MovingAverage = function(prices, interval, type="trail"){
  price_len = length(prices)
  ma = rep(NA, price_len)
  
  if (type == "trail"){
    for (i in interval:price_len){
      ma[i] = mean(prices[(i-interval+1):i])
    }
  }
  else if (type == "central"){
    fl = floor(interval/2)
    cl = ceiling(interval/2)
    for (i in fl:(price_len-cl)){
      ma[i] = mean(prices[(i-fl):(i+cl)])
    }
  }
  else{
    ma = prices
  }
  
  return(ma)
}



# Getting one year Stock Price Data (AFFLE)
price_data = PriceData("AFFLE.NS")
View(price_data)


# Plot Candle Stick Chart of Stock (Plotly)
install.packages("plotly")
library(plotly)

fig = plot_ly(price_data, x=price_data$Date, type="candlestick", 
              name="Price",
              open=price_data$Open, 
              close=price_data$Close,
              high=price_data$High,
              low=price_data$Low)

layout(fig, title="AFFLE Chart")

# Plot Moving Average
ma50 = MovingAverage(price_data$Close, 50, "trail")
ma200 = MovingAverage(price_data$Close, 200, "trail")

fig = add_lines(fig, x=price_data$Date, y=ma50, name="MA 50",
                line = list(color = 'black', width = 0.75), inherit = F)

fig = add_lines(fig, x=price_data$Date, y=ma200, name="MA 200",
                line = list(color = 'red', width = 1), inherit = F)
layout(fig, title="AFFLE Chart")

# Add Volume to Plot
vol_fig = plot_ly(price_data, x=price_data$Date, type="bar", 
                  name="Volume",
                  y=price_data$Volume)

vol_fig = layout(vol_fig, yaxis = list(title = "Volume"))
fig = layout(fig, yaxis = list(title = "Price"))

fig = subplot(fig, vol_fig, heights = c(0.7,0.2), nrows=2,
               shareX = TRUE, titleY = TRUE)

layout(fig, title="AFFLE Chart")
