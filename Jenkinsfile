pipeline {
    agent any
    
    environment {
        TERRAGRUNT_VERSION = "v0.58.9"
        TERRAFORM_VERSION = "1.9.3"
    }
    
    stages {
        stage('Install Terraform and Terragrunt') {
            steps {
                script {
                    // Install Terraform
                    sh "curl -o terraform.zip https://releases.hashicorp.com/terraform/${env.TERRAFORM_VERSION}/terraform_${env.TERRAFORM_VERSION}_linux_amd64.zip"
                    sh 'unzip terraform.zip'
                    sh 'mv terraform /usr/local/bin/'
                    sh 'rm terraform.zip'

                    // Install Terragrunt
                    sh "curl -L -o terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${env.TERRAGRUNT_VERSION}/terragrunt_linux_amd64"
                    sh 'chmod +x terragrunt'
                    sh 'mv terragrunt /usr/local/bin/'
                }
            }
        }

        stage('Checkout') {
            steps {
                // Checkout the code from the repository
                git branch: 'main', url: 'https://github.com/agustinkiko/legalmatch-test.git'
            }
        }
        
        stage('Terraform Init & Apply Dev') {
            steps {
                dir('env/dev') {
                    script {
                        withEnv(["AWS_PROFILE=legalmatch"]) {
                            sh 'terragrunt init'
                            sh 'terragrunt apply -auto-approve'
                        }
                    }
                }
            }
        }
        
        stage('Terraform Init & Apply Staging') {
            steps {
                dir('env/staging') {
                    script {
                        withEnv(["AWS_PROFILE=legalmatch"]) {
                            sh 'terragrunt init'
                            sh 'terragrunt apply -auto-approve'
                        }
                    }
                }
            }
        }
        
        stage('Terraform Init & Apply Prod') {
            steps {
                dir('env/prod') {
                    script {
                        withEnv(["AWS_PROFILE=legalmatch"]) {
                            sh 'terragrunt init'
                            sh 'terragrunt apply -auto-approve'
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace after the build
            cleanWs()
        }
        
        success {
            // Notify success
            echo 'Terraform deployment succeeded!'
        }
        
        failure {
            // Notify failure
            echo 'Terraform deployment failed!'
        }
    }
}
