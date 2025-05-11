FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN update-ca-certificates

# Need to install bash first if using a minimal base image, but ubuntu:latest has it.
RUN curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | bash

# Add tiup to the PATH for the root user
ENV PATH="/root/.tiup/bin:${PATH}"

ARG TIDB_VERSION=v7.5.2
ARG PLAYGROUND_VERSION=v1.16.2
ENV TIDB_VERSION=${TIDB_VERSION}
ENV PLAYGROUND_VERSION=${PLAYGROUND_VERSION}

RUN tiup install tikv:${TIDB_VERSION}
RUN tiup install tidb:${TIDB_VERSION}
RUN tiup install pd:${TIDB_VERSION}
RUN tiup install grafana:${TIDB_VERSION}
RUN tiup install tiflash:${TIDB_VERSION}
RUN tiup install playground:${PLAYGROUND_VERSION}

# Expose necessary ports
# TiDB server port (for SQL clients)
EXPOSE 4000
# grafana port
EXPOSE 3000
# Dashboard port
EXPOSE 2379

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
