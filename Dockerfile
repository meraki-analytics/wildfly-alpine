FROM openjdk:8-jre-alpine


# -- Install required packages
RUN apk update \
    && apk add curl \
    && rm -rf /var/cache/apk/*


# -- Add best practices from the jboss/base image. See https://github.com/jboss-dockerfiles/base/blob/master/Dockerfile.
RUN addgroup -S jboss -g 1000 \
    && mkdir /opt \
    && adduser -u 1000 -S -G jboss -h /opt/jboss -s /sbin/nologin -g "JBoss User" jboss \
    && chmod 755 /opt/jboss

WORKDIR /opt/jboss


# -- Install WildFly per jboss/wildfly image. See https://github.com/jboss-dockerfiles/wildfly/blob/master/Dockerfile.
# -- Used under the MIT License (https://github.com/jboss-dockerfiles/wildfly/blob/master/LICENSE).
ENV WILDFLY_VERSION 12.0.0.Final
ENV WILDFLY_SHA1 b2039cc4979c7e50a0b6ee0e5153d13d537d492f
ENV JBOSS_HOME /opt/jboss/wildfly

RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

EXPOSE 8080

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
