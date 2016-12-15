# Install ubuntu latest
FROM ubuntu:latest

# Configuration variables Linux
ENV DEBIAN_FRONTEND noninteractive

# Configuration variables JAVA
ENV PATH ["$PATH:/opt/java/bin:/opt/java/jre/bin"]
ENV JAVA_HOME /opt/java
ENV JAVA_VERSION 8u112
ENV JAVA_BUILD b15

# Configuration variables JIRA
ENV JIRA_HOME /var/atlassian/jira 
ENV JIRA_INSTALL /opt/atlassian/jira 
ENV JIRA_VERSION 7.2.3

# Install JAVA 
# Install Atlassian JIRA and helper tools and setup initial home 
# directory structure. 
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes wget \
    && wget --quiet --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-${JAVA_BUILD}/jdk-${JAVA_VERSION}-linux-x64.tar.gz" \
    && mkdir -p                "${JAVA_HOME}" \
    && tar -zxf "jdk-${JAVA_VERSION}-linux-x64.tar.gz" --directory "${JAVA_HOME}" --strip-components=1 --no-same-owner \
    && rm                      "./jdk-${JAVA_VERSION}-linux-x64.tar.gz" \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && wget                    "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-${JIRA_VERSION}.tar.gz" --quiet \
    && tar -zxf                "atlassian-jira-core-${JIRA_VERSION}.tar.gz" --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && rm                      "./atlassian-jira-core-${JIRA_VERSION}.tar.gz" \
    && chmod -R 700            "${JIRA_INSTALL}/conf" \
    && chmod -R 700            "${JIRA_INSTALL}/logs" \
    && chmod -R 700            "${JIRA_INSTALL}/temp" \
    && chmod -R 700            "${JIRA_INSTALL}/work" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml"

# Copy databasebconfig settings
#COPY ./dbconfig.xml ./dbconfig.xml
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
