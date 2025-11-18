ARG ODOO_VERSION=18.0
FROM python:3.11-slim-bookworm

LABEL maintainer="Odoo Developer"
LABEL description="Odoo Community Backports (OCB) Development Environment"

# Set environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build dependencies
    build-essential \
    git \
    wget \
    curl \
    # PostgreSQL client
    postgresql-client \
    # Python dependencies
    python3-dev \
    libpq-dev \
    # LDAP dependencies
    libldap2-dev \
    libsasl2-dev \
    # XML/XSLT dependencies
    libxml2-dev \
    libxslt1-dev \
    # Image processing
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libtiff5-dev \
    # Fonts
    fonts-liberation \
    # wkhtmltopdf dependencies
    fontconfig \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    # Node.js and npm for building assets
    nodejs \
    npm \
    # Other utilities
    nano \
    vim \
    less \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf (for PDF reports)
RUN wget -q https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && rm wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Create odoo user
RUN useradd -ms /bin/bash -u 1000 odoo

# Set working directory
WORKDIR /opt/odoo

# Clone OCB repository
ARG ODOO_VERSION
RUN git clone --depth 1 --branch ${ODOO_VERSION} https://github.com/OCA/OCB.git /opt/odoo \
    && chown -R odoo:odoo /opt/odoo

# Install Python dependencies
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir -r /opt/odoo/requirements.txt

# Install additional development tools
RUN pip3 install --no-cache-dir \
    debugpy \
    ipython \
    ipdb \
    pylint-odoo \
    black \
    flake8 \
    watchdog

# Create necessary directories
RUN mkdir -p /var/lib/odoo /var/log/odoo /mnt/extra-addons /etc/odoo \
    && chown -R odoo:odoo /var/lib/odoo /var/log/odoo /mnt/extra-addons /etc/odoo

# Create symlink for odoo-bin to odoo command
RUN ln -s /opt/odoo/odoo-bin /usr/local/bin/odoo \
    && chmod +x /opt/odoo/odoo-bin

# Set PATH to include Odoo directory
ENV PATH="/opt/odoo:${PATH}"

# Switch to odoo user
USER odoo

# Set working directory
WORKDIR /opt/odoo

# Expose Odoo ports
EXPOSE 8069 8072

# Set default command
CMD ["odoo-bin"]
