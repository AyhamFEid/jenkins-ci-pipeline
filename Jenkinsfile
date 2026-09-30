pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install & Test') {
            steps {
                // Spin up a temporary Python container to run tests in isolation
                sh '''
                    docker run --rm \
                      -v "$(pwd)":/app \
                      -w /app \
                      python:3.11-slim \
                      bash -c "pip install -r requirements.txt && pytest"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ci-demo-app:${BUILD_NUMBER} ."
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
