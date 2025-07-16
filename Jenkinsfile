pipeline { 
    agent any

    environment {
        TF_DIR = './infrastructure'
        APP_DIR = './src'
        TERRAFORM_HOME = tool name: 'terraform', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
        PATH = "${TERRAFORM_HOME}:${env.PATH}"       
        TF_ROOT = 'infrastructure/' 
    }
    stages {
        stage('Build') {
            steps {
                script {
                 //   sh "mvn clean install -DskipTests"
                    sh """
                        echo 'Building the Spring Boot application...'
                    """
                    // s3Upload bucket: 'spring-boot-app-demo-bucket', file: '/src/target/spring-boot-app-demo-0.0.1-SNAPSHOT.jar', path: 'deployments/spring-boot-app-demo-0.0.1-SNAPSHOT.jar'
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
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'jeferson']]){
                        sh "cd ${TF_DIR} && terraform init && terraform plan"
                        sh "cd ${TF_DIR} && terraform apply -auto-approve"
                    }
                }
            }
        }
    }
}