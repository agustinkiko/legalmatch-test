# legalmatch-test

## Project Setup

```
project-root/
│
├── env/
│   ├── dev/
│   │   └── terragrunt.hcl
│   ├── staging/
│   │   └── terragrunt.hcl
│   └── prod/
│       └── terragrunt.hcl
│
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
│
└── terragrunt.hcl

```

## Modules
Modules folder contains the modules needed to create the infrastructure. In this case, it's only `modules/ec2/`\
`modules/ec2/main.tf` contains the TF code for creating the aws ec2 instance\
`modules/ec2/output.tf` contains the TF code for outputting the requested return values after creating the resource\
`modules/ec2/variables.tf` contains the TF code for variables the `main.tf` and `output.tf` are requiring\

```
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
│
```

## Setting Up Terragrunt
### Root terragrunt.hcl
`terragrunt.hcl`
```
terraform {
  source = "../modules/ec2_instance"
}
```
### Environment Configs
Each environment (Dev, Staging, Production) has its own terragrunt.hcl in the respective env/ directories.\

Example: `env/dev/terragrunt.hcl`

```
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/modules/ec2"
}

inputs = {
  instance_type = "t2.micro"
  ami           = "ami-060e277c0d4cce553" 
  key_name      = "dev-key"
  aws_profile   = "legalmatch"
  aws_region    = "ap-southeast-1"
}

```
Make sure to update ami and key_name with the right values for each environment.\

## Jenkins Pipeline Script
`Jenkinsfile`
```
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Choose the environment to deploy'
        )
    }

    environment {
        TERRAGRUNT_VERSION = "v0.58.9"
        TERRAFORM_VERSION = "1.9.3"
        AWS_PROFILE = "legalmatch"
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

        stage('Terraform Init & Apply') {
            steps {
                script {
                    def envDir = "env/${params.ENVIRONMENT}"
                    dir(envDir) {
                        withEnv(["AWS_PROFILE=${env.AWS_PROFILE}"]) {
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

```

### How to Use This
Run the Pipeline: When you kick off the pipeline in Jenkins, you'll be asked to pick the environment you want to deploy to (dev, staging, or prod).\
Deploy: The pipeline will handle deploying the infrastructure to the environment you chose, using the AWS profile legalmatch
