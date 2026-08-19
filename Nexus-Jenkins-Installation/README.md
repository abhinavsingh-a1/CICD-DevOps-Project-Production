
## 1.1 Install docker

Before running the scripts, run `docker-install.sh` on EC2 instance to install Docker.

# Docker Setup

```bash
chmod +x docker-install.sh
./docker-install.sh
```

# Jenkins Nexus Setup
```bash
sudo su
docker compose -p nexus up -d
```

Lets check containers -

```bash
docker ps
```

<img width="1429" height="54" alt="image" src="https://github.com/user-attachments/assets/3f17116b-1f85-4bf7-960f-a225797f17a9" />

Get public IP of EC2 instance -
```bash
curl ifconfig.me
```

Copy IP address and place it with port 8080. Get UI of Jenkins -

<img width="964" height="427" alt="image" src="https://github.com/user-attachments/assets/e7c3762e-8e12-4d08-8c18-d6e6498135b7" />



