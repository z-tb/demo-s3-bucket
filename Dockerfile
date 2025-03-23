# Use an official Python runtime as a parent image
FROM python:3.10-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY application/ /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Define environment variable
ENV NAME=SOME_VAR

# Expose port 8000 to the outside world
EXPOSE 80

# Use Gunicorn to serve the Flask app
# CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
CMD ["python", "app.py"]

# keep the container running by tailing an empty file, allowing some time to SSM into the container to debug
# CMD ["/bin/bash", "-c", "tail -f /dev/null"]

