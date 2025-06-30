pipeline { 
    agent any

    environment {
        TF_DIR                = './terraform'
    }
    stages {
        stage('Build') {
            steps {
                script {
                    // Build the Spring Boot application
                    sh 'mvn clean install -DskipTests'
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("sonarQube") {
                    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=springBootApp -Dsonar.projectName='springBootApp'"
                }
            }

        }        
        stage('Sonar QG') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }   
            }
        }
        stage('Deploy') {
            steps {
                script {
                    sh 'cd ${TF_DIR} && terraform init && terraform apply --auto-approve'
                }
            }
        }
    }
}

// TODO - Mover o app pra esse repositorio
// Add no TF
//   step pra criar a ec2 DONE
//   Deploy steps
//     pegar a ssh-key e fazer acesso remoto nessa maquina
//     copiar o artefato do s3 pra maquina local
//     java -jar app.jar
//   no jenkins
//     apos buildar e copiar artefato pro s3, disparar o job do TF