ARG AIRFLOW_VERSION=2.9.2
ARG PYTHON_VERSION=3.10

FROM apache/airflow:${AIRFLOW_VERSION}-python${PYTHON_VERSION}

ENV AIRFLOW_HOME=/opt/airflow

# Copy your requirements.txt
COPY requirements.txt .

# Install Airflow + all Python dependencies (including soda-core-postgres)
RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" -r requirements.txt

# Optional: verify installation
RUN pip show soda-core-postgres || echo "soda-core-postgres not installed"

# Set working directory
WORKDIR /opt/airflow
