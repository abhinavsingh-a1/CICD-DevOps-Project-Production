# error: current-context is not set 
<br/>
Your kubectl does not currently have a Kubernetes context configured. This is why it previously tried to connect to:<br/>
<br/>
http://localhost:8080<br/>
<br/>
and failed.<br/>
<br/>
Since you are setting up a Kubernetes cluster with a master/control-plane node, let's fix the kubeconfig properly rather than bypassing validation.<br/>
<br/>
1. Check whether your kubeadm admin configuration exists<br/>
<br/>
On your Kubernetes control-plane/master node, run:<br/>
<br/><br/>
sudo ls -l /etc/kubernetes/admin.conf<br/>
If you get something like:<br/><br/>
-rw------- 1 root root ... /etc/kubernetes/admin.conf<br/>
<br/>
that's good. It means kubeadm has created the administrator kubeconfig.<br/>
<br/>
2. Configure kubectl for your current Linux user<br/>
<br/>
Run:<br/>
<br/>
mkdir -p $HOME/.kube<br/>
<br/>
Then:<br/>
<br/>
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config<br/>
<br/>
Then change ownership:<br/>
<br/>
sudo chown $(id -u):$(id -g) $HOME/.kube/config<br/>
<br/>
Now check:<br/>
<br/>
kubectl config current-context<br/>
<br/>
You should get something similar to:<br/>
<br/>
kubernetes-admin@kubernetes<br/>
3. Test the Kubernetes API connection<br/>
<br/>
Run:<br/>
<br/>
kubectl cluster-info<br/>
<br/>
You should see something similar to:<br/>
<br/>
Kubernetes control plane is running at https://<IP>:6443<br/>
<br/>
Then:<br/>
<br/>
kubectl get nodes<br/>
<br/>
You should see your control-plane node:<br/>
<br/>
NAME            STATUS   ROLES           AGE   VERSION<br/>
master-node     Ready    control-plane   ...   v1.xx.x<br/>
<br/>
If you have already joined a worker:<br/>
<br/>
NAME            STATUS   ROLES           AGE   VERSION<br/>
master-node     Ready    control-plane   ...<br/>
worker-node     Ready    <none>          ...<br/>
