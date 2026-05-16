import pytest
from unittest.mock import MagicMock
from consumer import validate_message, process_message

# Tests for validate_message
def test_validate_valid_message():
    data = {
        'symbol': 'AAPL',
        'price': 298.21,
        'volume': 43749827,
        'timestamp': '2026-05-15T17:30:32'
    }
    assert validate_message(data) == True

def test_validate_missing_price():
    data = {
        'symbol': 'AAPL',
        'volume': 43749827,
        'timestamp': '2026-05-15T17:30:32'
    }
    assert validate_message(data) == False

def test_validate_empty_message():
    assert validate_message({}) == False

# Tests for process_message
def test_process_message_saves_to_db():
    data = {
        'symbol': 'AAPL',
        'price': 298.21,
        'volume': 43749827,
        'timestamp': '2026-05-15T17:30:32'
    }
    cursor = MagicMock()
    db = MagicMock()
    cache = MagicMock()

    result = process_message(data, cursor, db, cache)

    assert result == True
    cursor.execute.assert_called_once()  # verify DB was called
    db.commit.assert_called_once()       # verify commit happened
    cache.set.assert_called()            # verify Redis was called
