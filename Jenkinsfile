pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        SSH_PRIVATE_KEY       = credentials('REDIS_VM_SSH_PRIVATE_KEY')
        SSH_PUBLIC_KEY        = credentials('REDIS_VM_SSH_PUBLIC_KEY')
    }

    stages {
        stage('Prepare SSH Keys') {
            steps {
                sh '''
                    mkdir -p ~/.ssh
                    echo "$SSH_PRIVATE_KEY" > ~/.ssh/redis_vm_key
                    chmod 600 ~/.ssh/redis_vm_key
                '''
            }
        }

        stage('Update Terraform Variables') {
            steps {
                sh '''
                    echo "public_key = \\"$SSH_PUBLIC_KEY\\"" > terraform/terraform.tfvars
                '''
            }
        }

        stage('Terraform Init and Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                        terraform output -json > ../ansible/terraform_output.json
                    '''
                }
            }
        }

        stage('Update Ansible Inventory') {
            steps {
                sh '''
                    PUBLIC_IP=$(cat ansible/terraform_output.json | jq -r .public_ip.value)
                    echo "[redis_server]" > ansible/inventory.ini
                    echo "redis ansible_host=$PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/redis_vm_key" >> ansible/inventory.ini
                '''
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ansible') {
                    sh '''
                        export ANSIBLE_HOST_KEY_CHECKING=False
                        ansible-playbook -i inventory.ini redis_setup.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
} 