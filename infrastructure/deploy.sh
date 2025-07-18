#!/bin/bash

echo 'Starting deployment of Spring Boot application...'
sudo yum update -y && sudo yum install java-17-amazon-corretto-headless -y
sudo kill -9 $(ps aux | grep java | awk '{print $2}') || true
echo 'Starting S3 file copy...'
sudo mkdir -p /app && sudo chown -R ec2-user: /app
aws s3 cp s3://spring-boot-app-demo-bucket/deployments/demo-0.0.1-SNAPSHOT.jar /app/spring-boot-app-demo-0.0.1-SNAPSHOT.jar
echo 'Starting application...'
setsid nohup java -jar /app/spring-boot-app-demo-0.0.1-SNAPSHOT.jar > /app/spring-boot-app-demo.log 2>&1 < /dev/null &