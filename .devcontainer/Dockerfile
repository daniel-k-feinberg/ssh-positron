# Positron SSH Dev Container
ARG VARIANT="4.4"
FROM ghcr.io/rocker-org/devcontainer/tidyverse:${VARIANT}

# Set working directory
WORKDIR /home/rstudio/project

# Install system dependencies
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssh-server curl ca-certificates nano sqlite3 neofetch cmake \
        libmagick++-dev libarchive-dev libcurl4-openssl-dev libxml2-dev \
        libssl-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
        libfreetype6-dev libglpk40 libnode-dev libpng-dev libtiff5-dev \
        libjpeg-dev pandoc python3.12-venv \
    && su - rstudio -c "curl -LsSf https://astral.sh/uv/install.sh | sh" \
    && rm -rf /var/lib/apt/lists/*

# Add uv to the PATH
ENV PATH="/home/rstudio/.local/bin:${PATH}"

# Configure and prepare SSH server
RUN mkdir -p /var/run/sshd && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "rstudio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create the .ssh directory for the user who will log in
RUN mkdir -p /home/rstudio/.ssh && \
    chown rstudio:rstudio /home/rstudio/.ssh && \
    chmod 700 /home/rstudio/.ssh

# Expose ports for SSH and RStudio/Shiny Server
EXPOSE 22 8787 3838

# Default command: start OpenSSH in the foreground
CMD ["/usr/sbin/sshd","-D"]
