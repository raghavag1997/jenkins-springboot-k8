FROM openjdk:8-jdk-alpine
ARG JAR_FILE=target/*.jar
RUN addgroup -S raghav && adduser -S raghav -G raghav
COPY ${JAR_FILE} /home/raghav/app.jar
USER raghav
EXPOSE 8080
ENTRYPOINT ["java","-jar","/home/raghav/app.jar"]
