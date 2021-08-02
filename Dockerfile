From python:latest
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ./target/*.war /usr/local/tomcat/webapps/todo-web-application-mysql.war
CMD ["catalina.sh","run"]
