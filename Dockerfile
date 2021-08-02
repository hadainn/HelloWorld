From python:3.7.11-slim-buster
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ./target/*.war /usr/local/tomcat/webapps/todo-web-application-mysql.war
CMD ["catalina.sh","run"]
