# Copyright 2018 Mark Woo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM alpine:3.8

LABEL maintainer="Mark Woo, https://github.com/wuxinwei"

# Set this environment variable to True to set timezone on container start.
# Default container timezone as found under the directory /usr/share/zoneinfo/.
ENV SET_CONTAINER_TIMEZONE False
ENV CONTAINER_TIMEZONE Asia/Shanghai

# Elastalert directories
ENV CONFIG_DIR /opt/config
ENV RULES_DIRECTORY /opt/rules
ENV LOG_DIR /opt/logs

ENV ELASTALERT_CONFIG ${CONFIG_DIR}/elastalert_config.yaml
ENV ELASTALERT_SUPERVISOR_CONF ${CONFIG_DIR}/elastalert_supervisord.conf
ENV ELASTICSEARCH_HOST localhost
ENV ELASTICSEARCH_PORT 9200

# Elasticsearch TLS configuration
ENV ELASTICSEARCH_TLS False
ENV ELASTICSEARCH_TLS_VERIFY True

# ElastAlert writeback index
ENV ELASTALERT_INDEX elastalert_status

WORKDIR /opt

# Install software required for Elastalert and NTP for time synchronization.
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ca-certificates openssl-dev libmagic file-dev openssl libffi-dev python2 python2-dev py2-pip py2-yaml build-base gcc musl-dev tzdata openntpd git supervisor

# Install Elastalert.
RUN pip install -U pip && \
	pip install libmagic && \
	pip install "python-magic>=0.4.15" && \
	pip install "setuptools>=11.3" && \
	pip install elastalert

# Check libmagic
RUN python -c "import magic"

RUN mkdir -p "${CONFIG_DIR}" && \
    mkdir -p "${RULES_DIRECTORY}" && \
    mkdir -p "${LOG_DIR}" && \
    mkdir -p /var/empty

# Clean up.
RUN apk del python2-dev musl-dev gcc openssl-dev libffi-dev git && \
    rm -rf /var/cache/apk/*

# Copy the script used to launch the Elastalert when a container is started.
COPY ./start-elastalert.sh /opt/

# Make the start-script executable.
RUN chmod +x /opt/start-elastalert.sh

# Launch Elastalert when a container is started.
CMD ["/opt/start-elastalert.sh"]
