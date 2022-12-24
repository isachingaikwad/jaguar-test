pipeline {
    agent any

    tools {
       terraform 'terraform'
    }
    stages {
        stage('Tests') {
            steps {
                        echo 'Building..'
                        sh 'npm install'
                        echo 'Testing..'
                        sh 'npm test'
            }
        }

        stage('Git checkout') {
           steps{
                git branch: 'main', credentialsId: 'Github', url: 'https://github.com/isachingaikwad/jaguar-test.git'
                // sh "docker build . -t sachinmgaikwad185/jaguar-test-repo:v1.0"
                // sh "docker push sachinmgaikwad185/jaguar-test-repo:v1.0"
            }
        }

        stage('Build and push docker image') {
            steps {
                script {
                    def dockerImage = docker.build("sachinmgaikwad185/jaguar-test-repo:v1.0")
                    docker.withRegistry('', 'jaguar-test-repo') {
                        dockerImage.push('v1.0')
                    }
                }
            }
        }

        // 'Create Aoutoscalling infrastructure on AWS using terraform'

        stage('terraform format check') {
            steps{
                sh 'cd terraform'
                sh 'terraform fmt'
            }
        }
        stage('terraform Init') {
            steps{
                sh 'terraform init'
            }
        }
        stage('terraform apply') {
            steps{
                sh 'terraform apply --auto-approve'
            }
        }

    }
}




