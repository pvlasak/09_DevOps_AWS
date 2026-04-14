#!/usr/bin.env groovy

pipeline {   
    agent any
    stages {
        stage("test") {
            steps {
                script {
                    echo "Testing the application..."

                }
            }
        }
        stage("build") {
            steps {
                script {
                    echo "Building the application..."
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "Deploying the application..."
                    def dockerCmd = 'docker run -p 3080:3080 -d petrdeveloper/demo-app:1.1'
                    sshagent(['aws-ec2-credentials']) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.73.40.234 ${dockerCmd}"
                    }
                }
            }
        }               
    }
} 
