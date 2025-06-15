# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the backend server script and Firebase service account key into the container at /app
COPY backend_server.py /app/
COPY firebase-service-account.json /app/

# Make port 8081 available to the world outside this container
# Cloud Run will set the PORT environment variable, which uvicorn will use.
# Defaulting to 8081 if PORT is not set, as per backend_server.py.
EXPOSE 8081

# Define environment variable for the port, uvicorn will respect this.
# The PORT env var is automatically set by Cloud Run.
ENV PORT 8081

# Run backend_server.py when the container launches
# CMD ["uvicorn", "backend_server:app", "--host", "0.0.0.0", "--port", "8081"]
# Use $PORT environment variable which Cloud Run sets
CMD uvicorn backend_server:app --host 0.0.0.0 --port $PORT
