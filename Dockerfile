FROM openjdk:8-alpine


MAINTAINER kubesphere@yunify.com

# Some version information
LABEL io.kubesphere.s2i.version.maven="3.5.4" \
      io.k8s.description="Platform for building and running plain Java war applications" \
      io.k8s.display-name="Tomacat Applications" \
      io.kubesphere.tags="builder,java,war,tomcat" \
      io.kubesphere.s2i.scripts-url="image:///usr/local/s2i" \
      io.kubespehre.s2i.destination="/tmp" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      io.openshift.s2i.assemble-input-files="/deployments" \
      org.jboss.deployments-dir="/deployments" \
      com.yunify.deployments-dir="/deployments" \
      com.yunify.dev-mode="JAVA_DEBUG:false" \
      com.yunify.dev-mode.port="JAVA_DEBUG_PORT:5005"

EXPOSE 8080

ENV TOMCAT_VERSION 9.0.46
ENV LANG en_US.UTF-8
USER root

# Get and Unpack Tomcat
RUN apk add --update curl \
 && rm -rf /var/cache/apk/* \
 && curl http://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -o /tmp/catalina.tar.gz \
 && tar xzf /tmp/catalina.tar.gz -C /opt \
 && ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat \
 && rm /tmp/catalina.tar.gz \
 && apk add --update ttf-dejavu fontconfig

# Add roles
ADD tomcat-users.xml /opt/apache-tomcat-${TOMCAT_VERSION}/conf/

# Startup script
ADD deploy-and-run.sh /opt/apache-tomcat-${TOMCAT_VERSION}/bin/

RUN chmod 755 /opt/apache-tomcat-${TOMCAT_VERSION}/bin/deploy-and-run.sh \
 && rm -rf /opt/tomcat/webapps/examples /opt/tomcat/webapps/docs  \
 && chgrp -R 0 /opt/tomcat/webapps \
 && chmod -R g=u /opt/tomcat/webapps

COPY s2i /usr/local/s2i
RUN chmod 755 /usr/local/s2i/*

# Add run script as /opt/run-java/run-java.sh and make it executable
COPY run-java /opt/run-java/
RUN chmod 755 /opt/run-java/*


VOLUME [ "/opt/tomcat/logs", "/opt/tomcat/work", "/opt/tomcat/temp", "/tmp/hsperfdata_root" ]

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

CMD /opt/tomcat/bin/deploy-and-run.sh

