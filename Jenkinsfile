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
                // Bundle workspace files into a tar stream, send them to the container, and run tests
                sh '''
                    tar -cf - app tests requirements.txt | docker run --rm -i \
                      -w /app \
                      python:3.11-slim \
                      bash -c "tar -xf - && pip install --no-cache-dir -r requirements.txt && pytest"
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
