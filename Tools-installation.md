create new EC2 instance.
SSH instance and 

```
sudo apt update
```

Install docker -

```
git clone https://github.com/abhinavsingh-a1/PROJECT-1--CICD-DevOps-4-Production/
./docker-install.sh
```

# Other than root user, can execute docker command -
```
sudo chmod 666 /var/run/docker.sock
```

# validate docker command execute by user -

```
docker pull hello-world
```

<img width="637" height="108" alt="image" src="https://github.com/user-attachments/assets/16cec431-451c-43e7-bf47-9cdadbca3304" />

-d detached mode (in background)
first port 9000 is host port that will open on VM
second port 9000 is port of container

# Install Sonarqube

```
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```

Check docker image is running -

```
docker ps
```

<img width="1221" height="36" alt="image" src="https://github.com/user-attachments/assets/b6039b46-13ca-4195-9446-ee583a58233a" />

# Install Nexus

```
docker run -d --name Nexus -p 8081:8081 sonatype/nexus3:latest
```


