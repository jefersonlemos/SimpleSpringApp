pipeline { 
    agent any

    environment {
        TF_DIR = './infrastructure'
        APP_DIR = './src'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    sh "mvn clean install -DskipTests"
                }
            }
        }
        // stage('SonarQube Analysis') {
        //     steps {
        //         withSonarQubeEnv("sonarQube") {
        //             sh "mvn clean verify sonar:sonar -Dsonar.projectKey=springBootApp -Dsonar.projectName='springBootApp'"
        //         }
        //     }

        // }        
        // stage('Sonar QG') {
        //     steps {
        //         timeout(time: 5, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true
        //         }   
        //     }
        // }
        stage('Deploy') {
            steps {
                script {
                    sh "cd ${TF_DIR} && terraform init && terraform apply --auto-approve"
                }
            }
        }
    }
}