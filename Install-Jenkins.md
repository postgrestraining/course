# Provision EC2 instance

## Login to EC2 & Install aws cli

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version 
aws configure
```
## Install terraform

```
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
terraform -v
```

## If you have any terraform file, run the below commands

```
terraform init
terraform plan
terraform apply
```

## Install Jenkins   
Source : https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/

## Downloading and installing Jenkins

```
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

## Configuring Jenkins
Jenkins is now installed and running on your EC2 instance. To configure Jenkins:

Connect to http://<your_server_public_DNS>:8080 from your browser. 
You will be able to access Jenkins through its management interface:

1. sudo cat /var/lib/jenkins/secrets/initialAdminPassword
2. On the left-hand side, select Manage Jenkins, and then select Manage Plugins.
3. Select the Available tab, and then enter Amazon EC2 plugin at the top right.
4. Select the checkbox next to Amazon EC2 plugin, and then select Install without restart.
5. Add amazon EC2 plugin

### Create Jenkins-Terraform pipeline to create RDS Instance

### Destroy the instance

### Create a default pipeline to create an RDS instance.
