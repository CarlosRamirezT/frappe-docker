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
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    git \
    curl \
    sudo \
    wget \
    build-essential \
    python3-dev \
    python3-pip \
    libmysqlclient-dev \
    mariadb-client \
    libjpeg8-dev \
    liblcms2-dev \
    libwebp-dev \
    libtiff5-dev \
    libopenjp2-7-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libx11-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-glx0-dev \
    libxcb-shm0-dev \
    libxcb-render0-dev \
    libxi-dev \
    libxtst-dev \
    libxcomposite-dev \
    libxdamage-dev \
    libxfixes-dev \
    libxext-dev \
    libxrandr-dev \
    libdbus-1-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libv4l-dev \
    libglib2.0-dev \
    libsasl2-dev \
    libffi-dev \
    libjpeg62-turbo-dev \
    libfontconfig1-dev \
    libxslt1-dev \
    libxml2-dev \
    libexif-dev \
    libxrender1 \
    fonts-cantarell \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-base \
    xfonts-scalable \
    poppler-utils \
    tcl8.6-dev \
    tk8.6-dev \
    uuid-dev \
    libssl-dev \
    libreadline-dev \
    libbz2-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libffi-dev \
    libgdbm-dev \
    libc6-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libdb5.3-dev \
    libexpat1-dev \
    liblzma-dev \
    libffi-dev \
    libssl-dev \
    libncurses-dev \
    libdb-dev \
    libgdbm-dev \
    tk-dev \
    zlib1g-dev \
    libffi-dev \
    libssl-dev \
    libpng-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
