import json
import redis
import psycopg2
from kafka import KafkaConsumer
from datetime import datetime

def validate_message(data):
    """Check if message has all required fields"""
    required_keys = ['symbol', 'price', 'volume', 'timestamp']
    return all(key in data for key in required_keys)

def process_message(data, cursor, db, cache):
    """Save stock price to PostgreSQL and Redis"""
    # Save to PostgreSQL (historical storage)
    cursor.execute(
        "INSERT INTO stock_prices (symbol, price, volume, timestamp) VALUES (%s, %s, %s, %s)",
        (data['symbol'], data['price'], data['volume'], data['timestamp'])
    )
    db.commit()
    print(f"💾 Saved to PostgreSQL!")

    # Save to Redis (live cache)
    cache.set(f"price:{data['symbol']}", data['price'])
    cache.set(f"updated:{data['symbol']}", data['timestamp'])
    print(f"⚡ Updated Redis cache!")
    return True

if __name__ == '__main__':
    # Connect to Kafka
    consumer = KafkaConsumer(
        'stock-prices',
        bootstrap_servers=['kafka:29092'],
        value_deserializer=lambda x: json.loads(x.decode('utf-8')),
        auto_offset_reset='earliest',
        group_id='tradestack-consumer'
    )
    # Connect to PostgreSQL
    db = psycopg2.connect(
        host='postgres',
        database='tradestack',
        user='tradestack',
        password='tradestack123'
    )
    cursor = db.cursor()
    # Connect to Redis
    cache = redis.Redis(host='redis', port=6379, decode_responses=True)

    print("🚀 TradeStack Consumer Started!")
    print("👂 Listening for stock prices...")

    for message in consumer:
        data = message.value
        print(f"\n📨 Received: {data['symbol']} ${data['price']}")
        if validate_message(data):
            process_message(data, cursor, db, cache)
        else:
            print(f"⚠️ Invalid message received: {data}")
