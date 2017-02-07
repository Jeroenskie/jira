# Install ubuntu latest
FROM ubuntu:latest

# Configuration variables Linux
ENV DEBIAN_FRONTEND noninteractive

# Configuration variables JAVA
ENV PATH ["$PATH:/opt/java/bin:/opt/java/jre/bin"]
ENV JAVA_HOME /opt/java
ENV JAVA_VERSION 8u121
ENV JAVA_BUILD b13

# Configuration variables JIRA
ENV JIRA_HOME /var/atlassian/jira 
ENV JIRA_INSTALL /opt/atlassian/jira 
ENV JIRA_VERSION 7.3.1

#Make SQL database backup.
# RUN set -x \
#	&& mkdir /tmp/`date +\%Y\%m\%d`_BackupJIRAdb${JIRA_VERSION} \
#	&& pg_dump -h 192.168.178.100 -Fc -o -U jiradbuser jiradb | gzip > /tmp/`date +\%Y\%m\%d`_BackupJIRAdb${JIRA_VERSION}/jiradb_FULL.sql.gz

# Install JAVA 
# Install Atlassian JIRA and helper tools and setup initial home 
# directory structure 
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes wget \
    && wget --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-${JAVA_BUILD}/e9e7ea248e2c4826b92b3f075a80e441/jdk-${JAVA_VERSION}-linux-x64.tar.gz" \
    && mkdir -p                "${JAVA_HOME}" \
    && tar -zxf "jdk-${JAVA_VERSION}-linux-x64.tar.gz" --directory "${JAVA_HOME}" --strip-components=1 --no-same-owner \
    && rm                      "./jdk-${JAVA_VERSION}-linux-x64.tar.gz" \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && wget                    "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz" \
    && tar -zxf                "atlassian-jira-software-${JIRA_VERSION}.tar.gz" --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && rm                      "./atlassian-jira-software-${JIRA_VERSION}.tar.gz" \
    && chmod -R 700            "${JIRA_INSTALL}/conf" \
    && chmod -R 700            "${JIRA_INSTALL}/logs" \
    && chmod -R 700            "${JIRA_INSTALL}/temp" \
    && chmod -R 700            "${JIRA_INSTALL}/work" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml"
	
# Copy databasebconfig settings
COPY ./dbconfig.xml "${JIRA_HOME}/dbconfig.xml"

# Wat doet dit precies?
COPY "docker-entrypoint.sh" "/"
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose default HTTP connector port. 
EXPOSE 8080 

# Set volume mount points for installation and home directory. Changes to the 
# home directory needs to be persisted as well as parts of the installation 
# directory due to eg. logs. 
VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs"]

# Set the default working directory as the installation directory. 
WORKDIR ${JIRA_HOME}

# Run Atlassian JIRA as a foreground process by default. 
CMD ["/opt/atlassian/jira/bin/catalina.sh", "run"]
