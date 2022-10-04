properties([
    parameters([
        string(
            name: 'PROJECT_ID',
            description: '(Required) The target GCS project ID.'
        ),
        string(
            name: 'SOURCE_REPO',
            description: '(Required) Which source repo to copy to GCS.'
        ),
        string(
            name: 'SOURCE_REPO_REF',
            defaultValue:  'main',
            description: '(Optional) Which source repo branch on the repo to copy to GCS.'
        ),
        string(
            name: 'SOURCE_PATH',
            defaultValue: '.',
            description: '(Optional) Directory path from the root of repository to copy'
        ),
        string(
            name: 'GCS_BUCKET',
            description: '(Required) Specify GCS Bucket fullname'
        ),
        string(
            name: 'GCS_PATH',
            defaultValue: '.',
            description: '(Optional) Directory path on the GCS Bucket to copy the repo files'
        )
    ])
])


/*
    Since this pipeline isn't meant to be dynamic and should only live in one place, the following are static values that shouldn't change between runs.
*/
def unitCode            = "tlz"
def gcpProjectId        = "${params.PROJECT_ID}"
def sourceRepo          = "${params.SOURCE_REPO}"
def sourceRepoRef       = "${params.SOURCE_REPO_REF}"
def sourceRepoPath      = "${params.SOURCE_PATH}"
def gcsBucket           = "${params.GCS_BUCKET}"
def gcsPath             = "${params.GCS_PATH}"

def jenkinsCloud        = "kubernetes"
def jenkinsNamespace    = "lz-bu-${unitCode}"
def jenkinsSvcAcct      = "${gcpProjectId}"
def tfVersion           = "0.13.5"
def gitCreds            = "gitlab-sa-token"

pipeline {
    agent {
        kubernetes {
            cloud "${jenkinsCloud}"
            label "${env.BUILD_TAG}"
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  namespace: ${jenkinsNamespace}
  labels:
    component: ci
spec:
  # Use service account that can deploy to all namespaces
  serviceAccountName: ${jenkinsSvcAcct}
  containers:
  - name: terraform
    image: hashicorp/terraform:${tfVersion}
    command:
    - cat
    tty: true
  - name: gcloud
    image: google/cloud-sdk:315.0.0
    command:
    - cat
    tty: true
"""
        }
    }
    stages {
        stage('Clone source Repo') {
            steps {
                container('gcloud') {
                    dir('workdir') {
                        git url: sourceRepo, credentialsId: gitCreds, branch: sourceRepoRef
                    }
                }
            }
        }

        stage('Copy to bucket') {
            steps {
                container('gcloud') {
                    dir('workdir') {
                        script {
                            try {
                                echo 'Running gsutil rsync...'
                                sh "ls -l"
                                sh """
                                    gsutil rsync -d -r ./${sourceRepoPath} gs://${gcsBucket}/${gcsPath}
                                """
                            }
                            catch (exc) {
                                error('Copy failed!')
                                currentBuild.result = 'FAILURE'
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Cleaning up!'
            container('gcloud') {
                sh """
                    echo 'debug out ..'
                    gsutil ls -l gs://${gcsBucket}/${gcsPath}
                """
            }
            dir('workdir') {
                sh "rm -rf ./*"
            }
        }
    }
}