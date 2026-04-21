@Library('lz-jenkins-shared-lib@master') _

properties([
    parameters([
        string(
            name: 'TF_MODULE_REPO',
            defaultValue: 'https://github.com/codepil/terraform-code-bits/bu-project',
            description: '(Required) The Terraform module URI to be used in execution.'
        ),
        string(
            name: 'TF_MODULE_PATH',
            defaultValue: '.',
            description: '(Required) The path to the target module in this repo.'
        ),
        string(
            name: 'TF_MODULE_REF',
            defaultValue: 'master',
            description: '(Required) The git ref (branch, tag, commit) to be executed.'
        ),
        string(
            name: 'TF_STATE_BUCKET',
            defaultValue: '',
            description: '(Required) The GCS bucket containing the target Terraform state'
        ),
        string(
            name: 'TF_STATE_PREFIX',
            defaultValue: '',
            description: '(Optional) The GCS bucket prefix for Terraform state'
        ),
        string(
            name: 'CHANGE_TICKET',
            defaultValue: '',
            description: '(Future State) The change ticket number associated with this change.'
        ),
        string(
            name: 'TF_COMMAND',
            defaultValue: 'terraform state list',
            description: 'Terraform command to execute'
        ),
        string(
            name: 'GIT_CRED_ID',
            defaultValue: 'gitlab-sa-token',
            description: 'Jenkins credential ID for the git token to be used for SCM cloning.'
        ),
    ])
])

pipeline {
    agent {
        kubernetes {
            cloud 'lz-automation'
            label "${env.BUILD_TAG}"
            defaultContainer 'jnlp'
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  namespace: lz-automation
  labels:
    component: ci
spec:
  # Use service account that can deploy to all namespaces
  serviceAccountName: lz-automation-master-tf
  containers:
  - name: terraform
    image: hashicorp/terraform:0.13.5
    command:
    - cat
    tty: true
'''
        }
    }
    stages {
        stage('Setup') {
            steps {
                container('terraform') {
                    script {
                        sh "echo 'Pipeline parameters: ${params}'"
                        // Create executable scripts from resources
                        def tfWrapper = libraryResource 'com/example/cicd/tf-wrapper.sh'
                        dir('scripts') {
                            writeFile file: './tf-wrapper.sh', text: tfWrapper
                            sh 'chmod +x ./tf-wrapper.sh'
                        }
                        // Configure git credentials
                        withCredentials([usernamePassword(credentialsId: params.GIT_CRED_ID, usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                            sh "scripts/tf-wrapper.sh configure_git $GIT_USER $GIT_PASS"
                        }
                    }
                }
            }
        }
        stage('Prepare') {
            steps {
                container('terraform') {
                    // Fetch 'TF_MODULE' and use it as basis for Terraform state
                    dir('module-repo') {
                        git url: params.TF_MODULE_REPO, credentialsId: params.GIT_CRED_ID, branch: params.TF_MODULE_REF
                    }
                    dir('workdir') {
                        sh "../scripts/tf-wrapper.sh terraform_init ${params.TF_STATE_BUCKET} ${params.TF_STATE_PREFIX} ../module-repo/${params.TF_MODULE_PATH}"
                    }
                }
            }
        }
        stage('Terraform Command') {
            steps {
                container('terraform') {
                    dir('workdir') {
                        sh "${params.TF_COMMAND}"
                    }
                }
            }
        }
    }
}
