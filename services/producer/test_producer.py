import pytest
from producer import fetch_stock_price

def test_fetch_valid_stock():
    result = fetch_stock_price('AAPL')
    assert result is not None
    assert result['symbol'] == 'AAPL'
    assert result['price'] > 0
    assert result['volume'] > 0
    assert 'timestamp' in result

def test_fetch_invalid_stock():
    result = fetch_stock_price('INVALID123')
    assert result is None

def test_fetch_returns_correct_keys():
    result = fetch_stock_price('GOOGL')
    assert 'symbol' in result
    assert 'price' in result
    assert 'volume' in result
    assert 'timestamp' in result
