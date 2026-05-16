import json
import time
import yfinance as yf
from kafka import KafkaProducer
from datetime import datetime

# Stocks we want to monitor
STOCKS = ['AAPL', 'GOOGL', 'TSLA', 'MSFT', 'AMZN']

def fetch_stock_price(symbol):
    try:
        ticker = yf.Ticker(symbol)
        info = ticker.fast_info
        return {
            'symbol': symbol,
            'price': round(float(info.last_price), 2),
            'volume': int(info.three_month_average_volume),
            'timestamp': datetime.now().isoformat()
        }
    except Exception as e:
        print(f"Error fetching {symbol}: {e}")
        return None

if __name__ == '__main__':
     # Connect to Kafka
    producer = KafkaProducer(
        bootstrap_servers=['kafka:29092'],
        value_serializer=lambda x: json.dumps(x).encode('utf-8')
    )
    print("🚀 TradeStack Producer Started!")
    print(f"Monitoring: {STOCKS}")
    
    while True:
        print(f"\n📊 Fetching prices at {datetime.now().strftime('%H:%M:%S')}")
        for symbol in STOCKS:
            data = fetch_stock_price(symbol)
            if data:
                 # Send to Kafka topic "stock-prices"
                producer.send('stock-prices', value=data)
                print(f"✅ {data['symbol']}: ${data['price']}")
        producer.flush()
        print("💾 All prices sent to Kafka!")
         # Wait 10 seconds before next fetch
        time.sleep(10)
