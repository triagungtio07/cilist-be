pipeline {  
  agent any 
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))   
  }
  environment {
    TAG = sh(returnStdout: true, script: 'echo $(git rev-parse --short HEAD)').trim()
  }
  stages {
     stage("Notify New Running Pipeline"){
        steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {  
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*START:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"                       
                    }
                     else if (env.BRANCH_NAME == 'staging') {
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*START:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"             
                    }
                    else if (env.BRANCH_NAME == 'main') {
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*START:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"          
                    }
                    else {
                        sh 'Nothing to Notify'
                    }
                }
            }
    }
    stage('Build Image') {
        steps {
            script {
                if (env.BRANCH_NAME == 'dev') { 
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*BUILDING IMAGES:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"       
                    sh 'docker build -t triagungtio/cilist-be:0.$BUILD_NUMBER-dev .'
                }
                 else if (env.BRANCH_NAME == 'staging') {
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*BUILDING IMAGES:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"      
                    sh 'docker build -t triagungtio/cilist-be:0.$BUILD_NUMBER-staging .'
                }
                else if (env.BRANCH_NAME == 'main') {
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*BUILDING IMAGES:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"      
                    sh 'docker build -t triagungtio/cilist-be:0.$BUILD_NUMBER-production .'
                }
                else {
                    sh 'echo Nothing to Build'
                }
            }
        }
    }
    stage('Push to Registry') {
        steps {
            script {
             if (env.BRANCH_NAME == 'dev') {
                slackSend channel: '#jenkins',
                color: 'good',
                message: "*PUSHING IMAGE TO REGISTRY:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"       
                sh 'docker push triagungtio/cilist-be:0.$BUILD_NUMBER-dev'
                }
                else if (env.BRANCH_NAME == 'staging') {
                slackSend channel: '#jenkins',
                color: 'good',
                message: "*PUSHING IMAGE TO REGISTRY:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"      
                sh 'docker push triagungtio/cilist-be:0.$BUILD_NUMBER-staging'
                }
                else if (env.BRANCH_NAME == 'main') {
                slackSend channel: '#jenkins',
                color: 'good',
                message: "*PUSHING IMAGE TO REGISTRY:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"      
                sh 'docker push triagungtio/cilist-be:0.$BUILD_NUMBER-production'
                }
                else {
                    sh 'echo Nothing to Push'
                }
        }
      }
    }
    stage('Deploy to Kubernetes Cluster') {
        steps {
        script {
             if (env.BRANCH_NAME == 'dev') {
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*DEPLOYING TO KUBERNETES:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                        sh 'cat deployment/dev/be_app.yaml | sed "s/{{NEW_TAG}}/0.$BUILD_NUMBER-dev/g" |  kubectl apply -f -'
                 }
                }
                else if (env.BRANCH_NAME == 'staging') {
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*DEPLOYING TO KUBERNETES:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                        sh 'cat deployment/staging/be_app.yaml | sed "s/{{NEW_TAG}}/0.$BUILD_NUMBER-staging/g" |  kubectl apply -f -'
                 }
                }
                else if (env.BRANCH_NAME == 'main') {
                    slackSend channel: '#jenkins',
                    color: 'good',
                    message: "*DEPLOYING TO KUBERNETES:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}"
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                        sh 'cat deployment/production/be_app.yaml | sed "s/{{NEW_TAG}}/0.$BUILD_NUMBER-production/g" |  kubectl apply -f -'
                 }
                }
                else {
                    sh 'echo Nothing to deploy'
                }
        }
      }
    }
    stage('Check Deployment') {
        steps {
        script {
             if (env.BRANCH_NAME == 'dev') {
                slackSend channel: '#jenkins',
                color: 'good',
                message: "*CHECKING DEPLOYMENT:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}" 

                        try {
                          withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                                sh "kubectl rollout status deployment  cilist-be-dev -n dev"
                         }
                        } catch (err) {
                            currentBuild.currentResult = 'FAILURE'
                            slackSend channel: '#jenkins',
                            color: 'danger',
                            message: "*DEPLOYMENT ISSUE:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} Start Revert Deployment" 

                            //Start undo deployment
                            withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                                sh "kubectl rollout undo deployment  cilist-be-dev -n dev"
                            }             
                            }  
                     
                    echo currentBuild.currentResult
                    if (currentBuild.currentResult == 'FAILURE'){
                        echo 'ERROR  INI WOI'

                    }
                       
                }    
                else if (env.BRANCH_NAME == 'staging') {
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                       
                        sh 'cat deployment/staging/be_app.yaml | sed "s/{{NEW_TAG}}/0.$BUILD_NUMBER-staging/g" |  kubectl apply -f -'
    
                 }
                }
                else if (env.BRANCH_NAME == 'main') {
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                
                        sh 'cat deployment/production/be_app.yaml | sed "s/{{NEW_TAG}}/0.$BUILD_NUMBER-production/g" |  kubectl apply -f -'
                     
                 }
                }
                else {
                    sh 'echo Nothing to deploy'
             }
         }
      }
    } 
}

 post {
    success {
        script {
           if (env.BRANCH_NAME == 'dev' || env.BRANCH_NAME == 'staging' || env.BRANCH_NAME == 'prod' ) {
                slackSend channel: '#jenkins',
                color: 'good',
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}" 
           } 
        }
    } 
    failure {
        script {
            if (env.BRANCH_NAME == 'dev' || env.BRANCH_NAME == 'staging' || env.BRANCH_NAME == 'prod' ) {
                slackSend channel: '#jenkins',
                color: 'danger',
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}"
            }
        }
    }
    
    }
        
}

