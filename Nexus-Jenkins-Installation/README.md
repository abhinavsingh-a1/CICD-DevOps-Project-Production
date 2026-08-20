
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

# Install Java
```bash
sudo apt update
sudo apt install fontconfig openjdk-21-jre
java -version
```

# Install Trivy
Follow official website for commands - https://trivy.dev/docs/latest/getting-started/installation/
```bash
sudo apt-get install wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
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

Get initial password string of Jenkins, copy string and paste in password - 

```bash
docker logs jenkins
```

<img width="1655" height="681" alt="image" src="https://github.com/user-attachments/assets/e5e3a6ec-0744-4657-8ec4-0cebabeba34b" />

<img width="983" height="899" alt="image" src="https://github.com/user-attachments/assets/7dc49a17-7427-4162-8cca-7345c22e93c9" />

<img width="990" height="829" alt="image" src="https://github.com/user-attachments/assets/12b1a0f7-c5e7-4225-b1c4-5b6df13dac23" />

Goto manage Jenkins >> Available Plugins >> 

Add >> 

Eclipse Temurin installer [Provides an installer for the JDK tool that downloads the Eclipse Temurin™ build based upon OpenJDK from the Adoptium Working Group.] <br/>
Config file provider [Ability to provide configuration files (e.g. settings.xml for maven, XML, groovy, custom files,...) loaded through the UI which will be copied to the job workspace.]<br/>
Pipeline Maven Integration [This plugin provides integration with Pipeline, configures maven environment to use within a pipeline job by calling sh mvn or bat mvn. The selected maven installation will be configured and prepended to the path.]<br/>
SonarQube Scanner [This plugin allows an easy integration of SonarQube, the open source platform for Continuous Inspection of code quality.]<br/>
Docker<br/>
Docker Pipeline<br/>
Docker Build Step<br/>
Kubernetes<br/>
Kubernetes Credentials<br/>
Kubernetes Client API<br/>
Kubernetes CLI<br/>
Maven Integration [This plugin provides a deep integration between Jenkins and Maven. It adds support for automatic triggers between projects depending on SNAPSHOTs as well as the automated configuration of various Jenkins publishers such as Junit.]<br/>
<br/>
Click on Install<br/>
<br/><br/>
Once plugins successfully install, configure them.<br/>
<br/>
Go to Manage Jenkins >> Tools >> Configure the tools -<br/>
<img width="1357" height="496" alt="image" src="https://github.com/user-attachments/assets/b8770795-89b9-467b-a733-567b7194db2b" />

<br/>Click Apply.
<br/>
<br/>
Lets create pipeline -
<br/>
Click on New Item -
<img width="807" height="835" alt="image" src="https://github.com/user-attachments/assets/1c678eb3-ba47-4c35-9f26-6300352655ab" />

<br/>Click Ok
<br/>Go to Pipeline >> Configure >>
<br/>
<img width="514" height="502" alt="image" src="https://github.com/user-attachments/assets/9f56476c-5e06-44ae-b0bb-7801d89aade6" /><br/>
<br/>
Under pipeline section, select Hello World & copy & paste multiple sections of Hello World -<br/>
<br/>
<img width="1299" height="708" alt="image" src="https://github.com/user-attachments/assets/ff2804de-e096-4e99-8113-b9321d309c51" /><br/>
<br/>
Lets start writing Pipeline -
<br/>
Add tools & first stage Git Checkout -
<br/>
<img width="1302" height="617" alt="image" src="https://github.com/user-attachments/assets/32766e60-bb2e-4900-99f2-14a8f2df1fb7" />

<br/>Use Pipeline syntex to create snippet.
<br/>Select git, paste repo URL, And add credentials with username & password -
<br/>
<img width="1531" height="788" alt="image" src="https://github.com/user-attachments/assets/7ffc6b40-c792-4bab-ad57-fced2f73354e" />

<br/>Click on generate pipeline script -

<br/><img width="1319" height="716" alt="image" src="https://github.com/user-attachments/assets/7d6770de-c481-4a59-96dd-9eaa42875e5d" />

<br/>Copy syntax and paste in pipeline under steps.
<br/><br/><br/>
Generate SonarQube Token. <br/>
Go to Sorqube. Under administrator >> Security >> Users <br/>
Create token >> Copy token -<br/><br/>
<img width="1357" height="926" alt="image" src="https://github.com/user-attachments/assets/ff95fa16-8536-407c-a5f4-fab6d5c7f443" />
<br/>
Add Sonarqube token as secret text credential in Jenkins<br/><br/>
Go to Add credentials. Create secret text. Paste in id field token from sonarqube and provide name -<br/>
<img width="525" height="743" alt="image" src="https://github.com/user-attachments/assets/4f54d1fc-4d50-4eb4-bdb3-ea3267605603" />
<br/>
Go to Manage Jenkins >> Systems >> SonarQube Installation >> Select server authentication token -
<br/>
<img width="688" height="574" alt="image" src="https://github.com/user-attachments/assets/c89c9bc6-73a5-4495-a513-f888acc0fe90" />

<br/>Apply.
<br/>
<br/>
Lets go back to pipeline syntax -
<br/>
<img width="1322" height="521" alt="image" src="https://github.com/user-attachments/assets/782a5b3a-5c65-491e-9cd3-c866ef47fd48" />

<br/>
Paste syntax in pipeline -
<br/>
<img width="1234" height="528" alt="image" src="https://github.com/user-attachments/assets/079a7fbe-eae9-41b9-837b-ca2b060cff5f" />

<br/>
Create Webhook in SonarQube -
<br/>
<img width="1313" height="335" alt="image" src="https://github.com/user-attachments/assets/9913b6dd-544c-4ed9-ab00-219024566e80" />

<br/>
Provide jenkins URL
<br/>
<img width="459" height="552" alt="image" src="https://github.com/user-attachments/assets/6858a28c-3ef1-42f0-9931-6722dfbd92a6" />

<br/>Create
<br/>

Add to JavaApplication's POM.xml file under section >> distributionManagement >> repository >> URL<br/>
Go to Nexus >> Nexus repository >> maven-released >> URL >> Copy<br/>
Paste in POM.xml inside URL<br/>
<br/>
<img width="1764" height="407" alt="image" src="https://github.com/user-attachments/assets/2056e376-9963-4c13-ab62-0360145d89be" />

<br/>
Add to JavaApplication's POM.xml file under section >> distributionManagement >> snapshotRepository >> URL<br/>
Go to Nexus >> Nexus repository >> maven-snapshot >> URL >> Copy<br/>
Paste in POM.xml inside URL<br/>
<br/>
Do above 2 changes in POM.xml file.
<br/>
<br/>
Go to Manage Jenkins >> Manage Files >> New Configuration -
<br/>
<img width="861" height="834" alt="image" src="https://github.com/user-attachments/assets/d187b247-a2aa-4c07-a453-f32551616143" />
<img width="765" height="193" alt="image" src="https://github.com/user-attachments/assets/198da1da-2c18-4119-a7f4-1a7d39fb6e16" />

<br/>
Now in Settings.xml file we will provide credentials for accessing Nexus -
<br/><br/><br/><br/>
Look for servers segment and add below 2 segments there & submit - 
<br/>
&lt;server&gt;<br/>
      &lt;id&gt;maven-releases&lt;/id&gt;<br/>
      &lt;username&gt;admin&lt;/username&gt;<br/>
      &lt;password&gt;admin123&lt;/password&gt;<br/>
    &lt;/server&gt;<br/>
<br/>
    &lt;server&gt;<br/>
      &lt;id&gt;maven-snapshots&lt;/id&gt;<br/>
      &lt;username&gt;admin&lt;/username&gt;<br/>
      &lt;password&gt;admin123&lt;/password&gt;<br/>
    &lt;/server&gt;<br/>
<br/>
<br/>
# For EKS, create service account (Follow EKS-Setup.md document) -
<br/>

<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

# NEXUS

Copy IP address and place it with port 8081. Get UI of Nexus, id = admin, password=admin123, select disable ananymous access -

<img width="475" height="483" alt="image" src="https://github.com/user-attachments/assets/f3dfba17-5e43-4f54-8339-b9d8cbd34ee8" />

Nexus is accessible to you -

<img width="1105" height="927" alt="image" src="https://github.com/user-attachments/assets/88b7b6bd-5828-4935-9b41-12f59d295e9f" />



