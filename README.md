# 09_DevOps_AWS
repository to practice manual application deployment on EC2 instance, setup of automated CI pipeline including deployment of docker image from Jenkins server.

On AWS is recommended to create an admin user and assign him UI and CLI access to AWS account <br>
Admin user has assigned admin user role that allows him to do all actions on all recoureses in the account <br>

## EC2 instance
- Can be created in the section *Compute - EC2*
- Access key pair can be generated during setting up the EC2 instace. The access key is saved on AWS and private key is automatically downloaded to localhost. 
- For Mac and Linux is recommended to use *.pem* format of the access key. Private key is recommended to be copied to the ~/.ssh and set read only permission for user. This access key provides secured access to EC2 instance. 
- Instance is running in the VPC of the selected region. Each availability zone in the VPC has its own subnet.

### Start docker image available in private DockerHub repository
- branch **feature/payment**
- Install docker on EC2 instance:
    - *sudo yum update*
    - *sudo yum install docker*
    - add user ec2-user to docker group to allow executation of docker commands without root privileges: *sudo usermod -aG docker $USER*, it can be checked in `/ect/group` 
    - start docker: *sudo service docker start*
    - login to DockerHub repository: *docker login*
    - run docker image from private repository: *docker run -p 3000:3080 -d <docker-image>* 

### Deploy Application on EC2 from DockerHub private repository from Jenkins server
- branch **jenkins-jobs**
- in Jenkins multibranch pipeline the credentials to access EC2 instance has to be created as SSH username with privated key. As private key a content of the file inside ~/.ssh folder can be used. 
- sshAgent plugin in Jenkins must be installed. <br> 
*def dockerCmd = 'docker run -p 3080:3080 -d petrdeveloper/demo-app:1.1'* <br>
                    *sshagent(['aws-ec2-credentials']) {* <br>
                        *sh "ssh -o StrictHostKeyChecking=no ec2-user@IP_ADDRESS ${dockerCmd}"* <br>
                    *}* <br>
- name of the docker image can be defined as environmental variable in the `environment` section inside the Jenkinsfile or defined as variable getting value from `pom.xml` and automatically incremented by maven built-in plugin. 

### Start an application on EC2 with docker-compose file
- branch **jenkins-jobs**
- docker-compose has to be installed on EC2 instance <br>
*sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose*<br>
*sudo chmod +x /usr/local/bin/docker-compose* <br>
- configure docker-compose.yaml file
- in Jenkinsfile: within sshAgent add *scp* command to copy the docker-compose.yaml into home directory on EC2, afterwards *ssh* command together with docker compose command should follow. 

### Extract docker-compose commands to a bash script and make image name dynamic
- branch **jenkins-jobs**
-  image name should not be hardcoded in Jenkinsfile or docker-compose.yaml file. Therefore, it is better to define it as and environmental variable in the Jenkinsfile 
- the variable value from Jenkinsfile can be forwarded to a bash script as parameter. Inside the bash script a linux environmental variable can be exported to be available on EC2 instance for *docker-compose*.
Commands inside the bash script intiate the execution of *docker-compose* :<br>
*#!/usr/bin/env bash* <br>
*export IMAGE=$1* <br>
*docker-compose -f docker-compose.yaml up --detach* <br>

*def shellCmds = "bash ./shell_cmds.sh ${IMAGE_NAME}"* <br>
*sshagent(['aws-ec2-credentials']) {* <br>
    *sh "scp shell_cmds.sh ec2-user@IP-address:/home/ec2-user"* <br>
    *sh "scp docker-compose.yaml ec2-user@IP-address:/home/ec2-user"* <br>
    *sh "ssh -o StrictHostKeyChecking=no ec2-user@IP-address ${shellCmds}"}* <br>
