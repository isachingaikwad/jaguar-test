#!groovy

pipeline {
    agent none
    stages {
        stage('Build the nodejs application') {
            steps {
                checkout scm
                sh "docker build . -t test-node-app:${VERSION}"
                sh "docker run test-node-app:${VERSION}"
            }
        }
    }
}
