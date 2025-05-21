# Use the official Python slim image (specify version for consistency)
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# Install extra packages if needed
RUN pip install gunicorn pymysql cryptography flake8 bandit

# Copy your application code
COPY app app
COPY migrations migrations
COPY microblog.py config.py boot.sh ./

# Make sure your startup script is executable
RUN chmod a+x boot.sh

# Environment variable for Flask
ENV FLASK_APP=microblog.py
ENV FLASK_ENV=production

# Compile translations (optional step; keep if your app uses Flask-Babel)
RUN flask translate compile || true

# Expose the port the app runs on
EXPOSE 5000

# Start the app using your custom script
CMD ["./boot.sh"]
