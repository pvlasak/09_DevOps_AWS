#!/usr/bin.env groovy
library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/pvlasak/jenkins-shared-library.git',
     credentialsId: 'github-credentials'])


pipeline {
    agent any
    tool {
        maven 'Maven3.9'
    }
    environment {
        IMAGE_NAME: 'petrdeveloper/demo-app:java-maven-app-1.1.0'
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
                    def dockerCmd = "docker run -p 8080:8080 -d ${IMAGE_NAME}"
                    sshagent(['aws-ec2-credentials']) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.73.40.234 ${dockerCmd}"
                    }
                }
            }
        }
}
'