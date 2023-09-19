# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

ARG FRAPPE_VERSION=v13.33.0
ARG ERPNEXT_VERSION=v13.34.0
ARG BENCH_VERSION=v5.2.1
ARG BENCH_NAME=frappe-bench
ARG FRAPPE_USER=frappe
ARG SITE_NAME=erp.development.com

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update the package repository and install essential dependencies
RUN apt-get update
RUN apt-get install -y pip git

# Copy the dependencies.txt file into the container
COPY requirements_bench.txt /tmp/
COPY requirements_frappe.txt /tmp/
COPY requirements_erpnext.txt /tmp/

RUN pip install --no-cache-dir -r /tmp/requirements_bench.txt
RUN pip install --no-cache-dir -r /tmp/requirements_frappe.txt
RUN pip install --no-cache-dir --default-timeout=120 -r /tmp/requirements_erpnext.txt


RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a non-root user
RUN useradd -ms /bin/bash ${FRAPPE_USER}

# Set the user as sudoer without password
RUN echo "frappe ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the frappe user
USER frappe
WORKDIR /home/frappe

# Clone ERPNext repository and set up bench
RUN git clone https://github.com/frappe/bench.git --branch ${BENCH_VERSION} --depth 1 bench-repo \
    && sudo pip3 install -e bench-repo

# Create a new bench environment
RUN bench init ${BENCH_NAME} --frappe-branch ${FRAPPE_VERSION} --python /usr/bin/python3 \
    && cd ${BENCH_NAME} \
    && bench get-app erpnext https://github.com/frappe/erpnext --branch ${ERPNEXT_VERSION} \
    && bench new-site ${SITE_NAME} \
    && bench --site ${SITE_NAME} install-app erpnext

# Expose the required ports
EXPOSE 8000 9000

# Start the development server
CMD ["bench", "start"]
