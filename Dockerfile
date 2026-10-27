# syntax=docker/dockerfile:1
# Multi-stage build for Dmitriy Boyarkin's Student API
# Image name : dmitriy-boyarkin-student-api:v1.0-dmitriy-boyarkin

# ---------- Stage 1: build with Gradle on an official JDK 17 image ----------
FROM gradle:8.10.2-jdk17 AS build
WORKDIR /home/gradle/src
COPY settings.gradle build.gradle ./
COPY src ./src
# Tests are executed in the Jenkins "Test" stage, so skip them here.
RUN gradle bootJar --no-daemon -x test

# ---------- Stage 2: small JRE runtime image ----------
FROM eclipse-temurin:17-jre-alpine
ARG APP_VERSION=v1.0-dmitriy-boyarkin
LABEL maintainer="Dmitriy Boyarkin" \
      org.opencontainers.image.title="dmitriy-boyarkin-student-api" \
      org.opencontainers.image.version="${APP_VERSION}"
ENV APP_VERSION=${APP_VERSION} \
    APP_STUDENT_NAME="Dmitriy Boyarkin" \
    SERVER_PORT=8080
RUN addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=build /home/gradle/src/build/libs/student-api.jar /app/app.jar
USER app
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
