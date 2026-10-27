// Jenkinsfile - CI pipeline of Dmitriy Boyarkin's Student API
// Job name: Dmitriy_Boyarkin_Student_API
pipeline {
    agent any   // must be an agent with JDK 17 and Docker access

    tools {
        jdk 'jdk17'   // name configured in Manage Jenkins > Tools
    }

    options {
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
    }

    triggers {
        githubPush()              // GitHub webhook
        pollSCM('H/2 * * * *')    // fallback polling every ~2 minutes
    }

    environment {
        STUDENT_NAME = 'Dmitriy Boyarkin'
        STUDENT_GROUP = 'IT2-2312'
        IMAGE_NAME   = 'dmitriy-boyarkin-student-api'
        IMAGE_TAG    = 'v1.0-dmitriy-boyarkin'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Student: ${STUDENT_NAME} (${STUDENT_GROUP}) - stage Checkout"
                checkout scm
                sh 'git log -1 --pretty=format:"Commit: %h %s (%an)"'
            }
        }

        stage('Build') {
            steps {
                echo "Student: ${STUDENT_NAME} (${STUDENT_GROUP}) - stage Build"
                sh '''
                    if [ -f ./gradlew ]; then chmod +x ./gradlew; G=./gradlew; else G=gradle; fi
                    $G clean bootJar --no-daemon
                '''
            }
        }

        stage('Test') {
            steps {
                echo "Student: ${STUDENT_NAME} (${STUDENT_GROUP}) - stage Test"
                sh '''
                    if [ -f ./gradlew ]; then G=./gradlew; else G=gradle; fi
                    $G test --no-daemon
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'build/test-results/test/*.xml'
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "Student: ${STUDENT_NAME} (${STUDENT_GROUP}) - building ${IMAGE_NAME}:${IMAGE_TAG}"
                sh 'docker build --build-arg APP_VERSION=${IMAGE_TAG} -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Verify') {
            steps {
                echo "Student: ${STUDENT_NAME} (${STUDENT_GROUP}) - stage Verify"
                sh '''
                    if docker image inspect ${IMAGE_NAME}:${IMAGE_TAG} >/dev/null 2>&1; then
                        echo "VERIFY OK: image ${IMAGE_NAME}:${IMAGE_TAG} exists"
                        docker images ${IMAGE_NAME}:${IMAGE_TAG}
                    else
                        echo "VERIFY FAILED: image ${IMAGE_NAME}:${IMAGE_TAG} not found"
                        exit 1
                    fi
                '''
            }
        }
    }

    post {
        success { echo "PIPELINE SUCCESS for ${STUDENT_NAME} (${IMAGE_NAME}:${IMAGE_TAG})" }
        failure { echo "PIPELINE FAILED for ${STUDENT_NAME} - see the failing stage above" }
    }
}
