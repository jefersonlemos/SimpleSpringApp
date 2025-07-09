# SimpleSpringApp

A basic Spring boot app that is built in Jenkins, tested with Sonar and deployed to an EC2.
This is the challenge number one from this (list)[https://github.com/diegopacheco/tech-resources/blob/master/devops-resources.md#code-challenges-round-1] and deploys this (app)[https://github.com/luisfneu/spring-boot-app-demo].

![App Diagram](image.png)



Como ajustar o kubectl deplois que criar o cluster

To add to kubectl

depois de criar o custer, atualizad o kubeconfig

```
aws eks update-kubeconfig --region us-east-1 --name poc-spring-boot-app-dev
```
aí depois add a role no ./kube/config

Luis
- --role-arn
- arn:aws:iam::443370700365:role/EKSAdmin-role

Jeferson
- --role-arn
- arn:aws:iam::077210449609:role/EKSAdmin-role