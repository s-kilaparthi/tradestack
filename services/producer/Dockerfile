# services/producer/Dockerfile

# Step 1: Start with Python base image
FROM python:3.11-slim

# Step 2: Set working directory inside container
WORKDIR /app

# Step 3: Copy and install requirements FIRST
COPY requirements.txt .
RUN pip install -r requirements.txt

# Step 4: Copy your code
COPY producer.py .

# Step 5: Run the producer
CMD ["python", "producer.py"]
