pipeline {
    agent any

    stages {
        stage('checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Shindekish/stage2-test.git']])
            }
        }

        stage('terraform init') {
            steps {
                sh "terraform init"
            }
        }

        stage('terraform validte') {
            steps {
                sh "terraform validte"
            }
        }

        stage('terraform format') {
            steps {
                sh "terraform fmt"
            }
        }
        stage('terraform action') {
            steps {
            

               sh "terraform ${action} –auto-approve"
            }
        }
    }

}
