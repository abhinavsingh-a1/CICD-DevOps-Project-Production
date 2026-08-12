<img width="1130" height="678" alt="image" src="https://github.com/user-attachments/assets/4b901de0-0a01-41f5-bed5-2b40e22c7e41" />

# Objective -
Below steps we will try to achieve. Project start with developer write code locally. Then -
1. Once developer test code on local system, he push code to GitHub
2. Once code is pushed to GitHub, Jenkins Pipeline will run. In Pipeline first: Code is compiled, which will find out syntax based error.
   2.1  For system level monitoring like how much CPU is used, how much RAM is used, we will use Node Exporter for Jenkins.
4. After successful code compilation, Maven will run the unit test cases.
5. Sonarqube will run the code quality check. Sonaqube will find Bugs, issues, code smell vulnerability issue inside code.
6. Trivy will find out if there is any sensitive data, also it will scan dependencies of application, if they are out dated or vulnerable. And then it generate the report. This report will be in specific format for better readability.
7. Build the application via Maven to application artifact.
8. This artifact will go to nexus repository so that we can do the release management.
9. After getting artifact, build the Docker image. And tag it. Tagging is done to define the different version of artifact.
10. Docker image will be pushed to Trivy to scan vulnerability in docker image.
11. Push docker image to DockerHub as private.
12. Before deploy application on kubernetes cluster, we need to be ensure that kubernetes cluster is secure, so we will scan the kubernetes cluster via KubeAudit.
13. Once application is deployed, need notification that pipeline is successful or failed.
14. Once deployment is done, monitor the application via Prometheus & Grafana. To monitor application, we will use blackbox exporter. BlackBox exporter will enable us to update about website traffic, website is up or not etc.



