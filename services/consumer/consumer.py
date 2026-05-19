import json
import os
import redis
import psycopg2
from kafka import KafkaConsumer
from datetime import datetime

# ── TESTABLE FUNCTIONS (no database needed) ──────────

def validate_message(data):
    """Check if message has all required fields"""
    # Make sure all 4 keys exist in the message
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

# ── MAIN EXECUTION (runs only when file is executed directly) ─

if __name__ == '__main__':
    # Connect to Kafka (message broker)
    consumer = KafkaConsumer(
        'stock-prices',
        bootstrap_servers=[os.environ.get('KAFKA_BROKER','kafka:29092')],
        value_deserializer=lambda x: json.loads(x.decode('utf-8')),
        auto_offset_reset='earliest',
        group_id='tradestack-consumer'
    )

    # Connect to PostgreSQL (credentials from environment variables)
    db = psycopg2.connect(
        host=os.environ.get('DB_HOST', 'postgres'),
        database=os.environ.get('DB_NAME', 'tradestack'),
        user=os.environ.get('DB_USER', 'tradestack'),
        password=os.environ.get('DB_PASSWORD', '')
    )
    cursor = db.cursor()

    # Connect to Redis (credentials from environment variables)
    cache = redis.Redis(
        host=os.environ.get('REDIS_HOST', 'redis'),
        port=int(os.environ.get('REDIS_PORT', 6379)),
        decode_responses=True
    )

    print("🚀 TradeStack Consumer Started!")
    print("👂 Listening for stock prices...")

    # Listen for messages forever
    for message in consumer:
        data = message.value
        print(f"\n📨 Received: {data['symbol']} ${data['price']}")

        # Validate before saving
        if validate_message(data):
            process_message(data, cursor, db, cache)
        else:
            print(f"⚠️ Invalid message received: {data}")
