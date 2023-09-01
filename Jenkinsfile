pipeline{
    agent any
    stages{
        stage('Build Maven'){
            steps{
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Stephentwo/springboot-reactApp']])
                sh 'mvn clean install'
            }
        }
        stage('Build Docker Image'){
            steps{
                script{ 
                    sh 'docker build -t chuksteve/spring-boot-react-app .'
                }
            }
        }
        stage('Push Image to DockerHub'){
            steps{
                script{
                    withCredentials([string(credentialsId: 'dockerhub-pwd', variable: 'dockerhubpwd')]) {
                    sh 'docker login -u chuksteve -p ${dockerhubpwd}'
                    }
                sh 'docker push chuksteve/spring-boot-react-app' 
                }
            }
        }
        stage('Create AWS resources using Terraform script'){
            steps{
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "jenkins-aws",
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        script{
                            checkout scm
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                        }
                    } 
            }
        }
    }
}