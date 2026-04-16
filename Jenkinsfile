#!/usr/bin/env groovy
library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/pvlasak/jenkins-shared-library.git',
     credentialsId: 'github-credentials'])


pipeline {
    agent any
    tools {
        maven 'Maven3.9'
    }
    stages {
       stage('increment version') {
                steps {
                    script {
                        sh 'mvn build-helper:parse-version versions:set \
                            -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                            versions:commit'
                        def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                        def version = matcher[0][1]
                        echo matcher[0][0]
                        env.TAG = "${version}-${BUILD_NUMBER}"
                        env.IMAGE_NAME = "petrdeveloper/demo-app:java-maven-${TAG}"
                    }
                }
            }
        stage("build app") {
            steps {
                script {
                    echo "Testing the application..."
                    sh "mvn clean package"
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
                    def ec2Instance = "ec2-user@3.73.40.234"
                    sshagent(['aws-ec2-credentials']) {
                        sh "scp shell_cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmds}"
                    }
                }
            }
        }
        stage('commit version update') {
            steps {
                 script {
                      withCredentials([usernamePassword(credentialsId: 'github-username-token', passwordVariable: 'TOKEN', usernameVariable:'USER')]) {
                          sh 'git config user.email "jenkins@example.com"'
                          sh 'git config user.name "jenkins"'
                          sh 'git status'
                          sh 'git branch'
                          sh 'git config --list'
                          sh "git remote set-url origin https://${USER}:${TOKEN}@github.com/pvlasak/09_DevOps_AWS.git"
                          sh 'git add .'
                          sh 'git commit -m "ci: version bump"'
                          sh 'git push origin HEAD:jenkins-jobs'
                      }
                 }
            }
        }
    }
}