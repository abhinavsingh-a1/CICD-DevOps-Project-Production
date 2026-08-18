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


Step by step what we will do is -
1. We will prepare network environment. We have to make sure the network is secure & isolated as well private.
2. Next we will prepare Kubernetes cluster where we will deploy our application and scan for vulnerability.
3. We will create multiple virtual machines within secure network so that we can install different servers like Sonarqube server, Nexus server, Jenkins and different monitoring tools.
4. Once all infra is setup, we will create a private Git repo.
5. Then we will push our source code.
6. Once we successfully push code in code repo, we will start working on CICD pipeline and will deploy our application.
7. Configure the mail notification to get the status of our pipeline. [failed/success)
8. Last, we will deploy monitoring system like Prometheus & Grafana. Here we will have to type of monitoring, system level monitoring for monitoring CPU usage, RAM usage & second is application level monitoring like traffic flow & application is live.

VPC - devops-vpc <br/>
Security-Group <br/>
Inbound rules -  <br/>
<table>
   <tr>
   <td> <b>TYPE </b></td>
   <td> <b> PORT</b></td>
   <td> <b> DESCRIPTION</b></td>
</tr>
<tr>
   <td> SMTP </td>
   <td>  PORT 25</td>
   <td>  To send email generally in corporate.</td>
</tr>
<tr>
   <td> Customer TCP</td>
   <td> PORT 3000-10000</td>
   <td> for the deployed application</td>
</tr>
<tr>
   <td> SSH </td>
   <td> PORT 22</td>
   <td> To access virtual machines</td>
</tr>
<tr>
   <td> Custom TCP  </td>
   <td> PORT 6443</td>
   <td> Required when kubernetes cluster is setup</td>
</tr>
<tr>
   <td> SMTPS </td>
   <td> PORT 465</td>
   <td> To send email from Jenkins server once pipelines finish or fail.</td>
</tr>
<tr>
   <td> Custom TCP 
</td>
   <td> PORT 30000-32767</td>
   <td> for deployment of applications when using VM as kubernetes cluster.</td>
</tr>
</table>
<br/>

Create 3 VM -<br/>
P1-DevOps-VM-Master<br/>
P1-DevOps-VM-Slave1<br/>
P1-DevOps-VM-Slave2<br/><br/>

Download MobaXTerm for remote computing.
Settings >> Configuration >> SSH ==>> Select SSH keepAlive
Create 3 seesion - 1 for master, 2 for slave nodes

Connect with VM via SSH & install kubernetes cluster.

# KUBERNETES SETUP
## 1. EXECUTE MASTER BASH FILE ON MASTER EC2 INSTANCE

---

## Prerequisite: Install Docker and runtime dependencies

Before running the master or worker setup scripts, run `docker-install.sh` on every node to install Docker and configure the container runtime.

```bash
chmod +x docker-install.sh
./docker-install.sh
```

---

## Run script

chmod +x k8s-master-clean.sh
./master-node-setup.sh

---

This script will -<br/>
Sets hostname to master<br/>
Disables swap<br/>
Configures kernel networking<br/>
Installs containerd<br/>
Enables SystemdCgroup<br/>
Installs kubeadm, kubelet, kubectl<br/>
Initializes cluster<br/>
Configures kubectl<br/>
Installs Calico network<br/>

## Below result will be executed on worked node -
kubeadm join :6443 --token ... --discovery-token-ca-cert-hash sha256:...

# 2. EXECUTE WORKER BASH FILE ON WORKER EC2 INSTANCE
---

## Run script

chmod +x *.sh
./worker-node-setup.sh

---

## Join cluster

sudo kubeadm join <MASTER-IP>:6443 \
--token <TOKEN> \
--discovery-token-ca-cert-hash sha256:<HASH> \
--v=5

---

# 🔍 VERIFY CLUSTER

kubectl get nodes

---

## ✅ Expected Output

master            Ready
worker-172-31-x   Ready
worker-172-31-x   Ready

---

# 📦 VERIFY PODS

kubectl get pods -A

All should be Running

---


### EXPLANATION IS GIVEN IN BASH FILE


```bash
#!/bin/bash
```

---------------------------------------------OLD VERSION----------------------------------------

From Step 1 - Step 4, copy all commands and ctrl+right click - paste in install.sh file - <br/>
vi install.sh <br/>
chmod +x install.sh <br/>
./ install.sh<br/>
<br/>
### 1. Update System Packages [On Master & Worker Node]

```bash
sudo apt-get update
```

### 2. Install Docker[On Master & Worker Node]

```bash
sudo apt install docker.io -y
sudo chmod 666 /var/run/docker.sock
```

### 3. Install Required Dependencies for Kubernetes[On Master & Worker Node]

```bash
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo mkdir -p -m 755 /etc/apt/keyrings
```

### 4. Add Kubernetes Repository and GPG Key[On Master & Worker Node]

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### 5. Update Package List[On Master & Worker Node]

```bash
sudo apt update
```

## Kubeadm is a tool to bootstrape, spin up Kubernetes cluster
## The kubelet is the main agent that runs on every worker node in a Kubernetes cluster. It takes configuration instructions, called PodSpecs, andmakes sure the containers described in them are running and healthy. It acts as the bridge between the control plane and the local node
## kubectl (pronounced "cube-control" or "cube-ctl") isthe primary command-line tool (CLI) used to communicate with and manage a Kubernetes cluster.

### 6. Install Kubernetes Components[On Master & Worker Node]

```bash
sudo apt install -y kubeadm=1.28.1-1.1 kubelet=1.28.1-1.1 kubectl=1.28.1-1.1
```

### 7. Initialize Kubernetes Master Node [On MasterNode]

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

### 8. Configure Kubernetes Cluster [On MasterNode]

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 9. Deploy Networking Solution (Calico) [On MasterNode]

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### 10. Deploy Ingress Controller (NGINX) [On MasterNode]

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.0/deploy/static/provider/baremetal/deploy.yaml
```






