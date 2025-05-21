pipeline {
    agent any

    environment {
        IMAGE_NAME = "hetapatel638/microblog"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/hetapatel638/microblog.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Lint (Code Quality)') {
            steps {
                sh "docker run --rm ${IMAGE_NAME}:latest flake8 app"
            }
        }

        stage('Security Scan') {
            steps {
                sh "docker run --rm ${IMAGE_NAME}:latest bandit -r app"
            }
        }

        stage('Test') {
            steps {
                // You can run tests inside the Docker container as well
                sh "docker run --rm ${IMAGE_NAME}:latest python -m unittest discover tests"
            }
        }

        stage('Deploy to Test Environment') {
            steps {
                // Stop and remove any old container first, then run a new one
                sh '''
                    docker stop microblog-test || true
                    docker rm microblog-test || true
                    docker run -d --name microblog-test -p 5000:5000 ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Release to Production (Push to Docker Hub)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag ${IMAGE_NAME}:latest $DOCKER_USER/microblog:latest
                        docker push $DOCKER_USER/microblog:latest
                    '''
                }
            }
        }

        stage('Monitoring') {
            steps {
                // Simple health check
                sh '''
                    sleep 5
                    curl --fail http://localhost:5000 || (echo "Health check failed!" && exit 1)
                '''
            }
        }
    }
    post {
        always {
            sh '''
                docker stop microblog-test || true
                docker rm microblog-test || true
            '''
        }
    }
}