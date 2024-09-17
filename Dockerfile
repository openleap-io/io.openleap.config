FROM amazoncorretto:21.0.4-alpine as builder
WORKDIR application
ARG JAR_FILE=target/openleap-config-exec.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM amazoncorretto:21.0.4-alpine
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT exec java org.springframework.boot.loader.JarLauncher
