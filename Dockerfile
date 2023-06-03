FROM amazoncorretto:17-alpine3.16
ARG artifact=build/libs/java-sb-*.jar
WORKDIR /opt/app
COPY ${artifact} app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
