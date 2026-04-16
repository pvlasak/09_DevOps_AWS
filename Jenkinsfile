#!/usr/bin.env groovy
library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/pvlasak/jenkins-shared-library.git',
     credentialsId: 'github-credentials'])


pipeline {
    agent any
    tools {
        maven 'Maven3.9'
    }
    environment {
        IMAGE_NAME='petrdeveloper/demo-app:java-maven-app-2.1.0'
    }
    stages {
        stage("build app") {
            steps {
                script {
                    echo "Testing the application..."
                    buildJar()
                }
            }
        }
        stage("build") {
            steps {
                script {
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "Deploying the application..."
                    def shellCmds = "bash ./shell_cmds.sh ${IMAGE_NAME}"
                    sshagent(['aws-ec2-credentials']) {
                        sh "scp shell_cmds.sh ec2-user@3.73.40.234:/home/ec2-user"
                        sh "scp docker-compose.yaml ec2-user@3.73.40.234:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.73.40.234 ${shellCmds}"
                    }
                }
            }
        }
    }
}