FROM amazoncorretto:17-alpine-jdk

EXPOSE 8080

COPY ./target/java-maven-app-* /usr/app/
WORKDIR /usr/app

CMD java -jar java-maven-app-*.jar