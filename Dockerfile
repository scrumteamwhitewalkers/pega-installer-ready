# Dockerfile
# Copyright (c) 2019  Pegasystems Inc.

# Base image to extend from
FROM openjdk:11

LABEL vendor="Pegasystems Inc." \
      name="Pega Platform Installation" \
      version="1.0.0"
    
MAINTAINER Systems Management
    
# Create common directory for mounting configuration and libraries
RUN mkdir -p /opt/pega && \
    chgrp -R 0 /opt/pega && \
    chmod -R g+rw /opt/pega

# Create directory for mounting distribution kit
RUN mkdir -p /opt/pega/kit && \
    chgrp -R 0 /opt/pega/kit && \
    chmod -R g+rw /opt/pega/kit

# Create common directory for mounting archives folder from distribution kit
RUN mkdir -p /opt/pega/kit/archives && \
    chgrp -R 0 /opt/pega/kit/archives && \
    chmod -R g+rw /opt/pega/kit/archives
      
# Create common directory for mounting scripts folder from distribution kit
RUN mkdir -p /opt/pega/kit/scripts && \
    chgrp -R 0 /opt/pega/kit/scripts && \
    chmod -R g+rw /opt/pega/kit/scripts
      
# Create common directory for mounting rules folder from distribution kit
RUN mkdir -p /opt/pega/kit/rules && \
    chgrp -R 0 /opt/pega/kit/rules && \
    chmod -R g+rw /opt/pega/kit/rules

# Create directory for mounting configuration files
RUN  mkdir -p /opt/pega/config  && \
     chgrp -R 0 /opt/pega/config && \
     chmod -R g+rw /opt/pega/config

# Create directory for mounting database vendor driver jars
RUN  mkdir -p /opt/pega/lib  && \
     chgrp -R 0 /opt/pega/lib && \
     chmod -R g+rw /opt/pega/lib

# Create directory for mounting secrets
RUN  mkdir -p /opt/pega/secrets  && \
     chgrp -R 0 /opt/pega/secrets && \
     chmod -R g+rw /opt/pega/secrets

# Create directory for mounting temporary installation and upgrade files
RUN  mkdir -p /opt/pega/temp  && \
     chgrp -R 0 /opt/pega/temp && \
     chmod -R g+rw /opt/pega/temp     

# Action input from user for install/upgrade
ENV ACTION=''

# kit URI
ENV KIT_URL=''

# Set up an empty JDBC URL which will, if set to a non-empty value, be used in preference
# to the "constructed" JDBC URL
ENV JDBC_URL='' \
    DB_TYPE='' \
    JDBC_CLASS='' \
    DB_USERNAME='' \
    DB_PASSWORD=''

# Load a default PostgreSQL driver on startup
ENV JDBC_DRIVER_URI=''

# Provide schema related information
ENV RULES_SCHEMA='' \
    DATA_SCHEMA='' \
    CUSTOMERDATA_SCHEMA=''

# Provide system related information
ENV SYSTEM_NAME='pega' \
    PRODUCTION_LEVEL='2' \
    ADMIN_PASSWORD='' \
    MT_SYSTEM=''   

# Provide customizable installation parameters
ENV BYPASS_UDF_GENERATION='' \
    BYPASS_PEGA_SCHEMA='' \
    ASSEMBLER='' \
    JDBC_CUSTOM_CONNECTION='' \
    BYPASS_TRUNCATE_UPDATESCACHE='false'

# Provide z/OS related information
ENV ZOS_PROPERTIES='' \
    DB2_ZOS_UDF_WLM=''

# UPGRADE RELATED PROPERTIES
# Source system details will be same as installer
# Target system details
# SKIP_RULES_MIGRATE is hidden flag to skip Rules Migration process during upgrade process
# SKIP_RULES_UPGRADE is hidden flag to skip Rules Upgrade process during upgrade process

ENV UPGRADE_TYPE='' \
    TARGET_RULES_SCHEMA='' \
    TARGET_ZOS_PROPERTIES='' \
    MIGRATION_DB_LOAD_COMMIT_RATE='100' \
    UPDATE_EXISITING_APPLICATIONS='false' \
    UPDATE_APPLICATIONS_SCHEMA='false' \
    RUN_RULESET_CLEANUP='' \
    REBUILD_INDEXES='' \
	SKIP_RULES_MIGRATE='false' \
	SKIP_RULES_UPGRADE='false'

# THREAD LEVEL FOR INSTALLER IMAGE
ENV MAX_IDLE='5' \
    MAX_WAIT='-1' \
    MAX_ACTIVE='10'

# Code set version
ENV CODESET_VERSION=''

# Installing dockerize for generating config files using templates
RUN curl -sL https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz | tar zxf - -C /bin/

COPY installer-conf /opt/pega/config

COPY scripts /scripts
RUN chmod -R g+x /scripts

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
CMD ["run"]
