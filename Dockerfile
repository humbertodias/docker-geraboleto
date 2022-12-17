# our base build image
FROM maven:3-openjdk-18 as build

# copy the project files
COPY ./pom.xml ./pom.xml

# build all dependencies
RUN mvn dependency:go-offline -B

# copy your other files
COPY ./src ./src

# build for release
RUN mvn package


# base image to build a JRE
FROM mcr.microsoft.com/java/jdk:17-zulu-alpine as jdk

# required for strip-debug to work
RUN apk add --no-cache binutils

# Build small JRE image
RUN $JAVA_HOME/bin/jlink \
    --verbose \
    --add-modules java.base,java.management,java.naming,java.net.http,java.security.jgss,java.security.sasl,java.sql,jdk.httpserver,jdk.unsupported,java.xml,java.prefs,java.desktop,java.instrument,java.logging,java.compiler,jdk.crypto.cryptoki \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /customjre

# main app image
FROM alpine:latest
ENV SERVER_PORT=8080
ENV JAVA_HOME=/jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# copy JRE from the base image
COPY --from=jdk /customjre $JAVA_HOME

# Depepency for pdf generation 
# br.com.caelum.stella/caelum-stella-boleto
RUN apk --update add fontconfig ttf-dejavu

# Add app user
ARG APPLICATION_USER=appuser
RUN adduser --no-create-home -u 1000 -D $APPLICATION_USER

# Configure working directory
RUN mkdir /app && \
    chown -R $APPLICATION_USER /app

USER 1000

COPY --chown=1000:1000 --from=build target/*.jar /app/app.jar
WORKDIR /app

EXPOSE 8080
ENTRYPOINT [ "/jre/bin/java", "-jar", "/app/app.jar" ]