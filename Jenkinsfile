pipeline {  
  agent any 
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))   
  }
  environment {
    GIT_COMMIT_SHORT = sh(returnStdout: true, script: '''echo $GIT_COMMIT | head -c 7''')
  }
  stages {
    stage('Prepare .env') {
        steps {
            sh 'echo GIT_COMMIT_SHORT=$(echo $GIT_COMMIT_SHORT) > .env'
        }
    }
    stage('Build Image') {
        steps {
            script {
                if (env.BRANCH_NAME == 'dev') {  
            sh 'cd /var/lib/jenkins/workspace/big_project_dev/backend && docker build -t triagungtio/cilist-be:$GIT_COMMIT_SHORT-dev .'                  
            sh 'cd /var/lib/jenkins/workspace/big_project_dev/frontend && docker build -t triagungtio/cilist-fe:$GIT_COMMIT_SHORT-dev .'                  
                }
                 else if (env.BRANCH_NAME == 'staging') {
            sh 'cd /var/lib/jenkins/workspace/big_project_dev/backend && docker build -t triagungtio/cilist-be:$GIT_COMMIT_SHORT-staging .'                  
            sh 'cd /var/lib/jenkins/workspace/big_project_dev/frontend && docker build -t triagungtio/cilist-fe:$GIT_COMMIT_SHORT-staging .'  
                }
                else if (env.BRANCH_NAME == 'main') {
            sh 'cd /var/lib/jenkins/workspace/big_project_dev/backend && docker build -t triagungtio/cilist-be:$GIT_COMMIT_SHORT-production .'                  
            sh 'cd /var/lib/jenkins/workspace/big_project_dev/frontend && docker build -t triagungtio/cilist-fe:$GIT_COMMIT_SHORT-production .' 
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
            sh 'docker push triagungtio/cilist-be:$GIT_COMMIT_SHORT-dev'
            sh 'docker push triagungtio/cilist-fe:$GIT_COMMIT_SHORT-dev'
                }
                else if (env.BRANCH_NAME == 'staging') {
            sh 'docker push triagungtio/cilist-be:$GIT_COMMIT_SHORT-staging'
            sh 'docker push triagungtio/cilist-fe:$GIT_COMMIT_SHORT-staging'
                }
                else if (env.BRANCH_NAME == 'main') {
            sh 'docker push triagungtio/cilist-be:$GIT_COMMIT_SHORT-production'
            sh 'docker push triagungtio/cilist-fe:$GIT_COMMIT_SHORT-production'
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
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                        sh "kubectl apply -f deployment/dev/configmap.yaml"
                        sh 'cat deployment/dev/be_app.yaml | sed "s/{{NEW_TAG}}/$GIT_COMMIT_SHORT-dev/g" |  kubectl apply -f -'
                        sh 'cat deployment/dev/fe_app.yaml | sed "s/{{NEW_TAG}}/$GIT_COMMIT_SHORT-dev/g" |  kubectl apply -f -'
                        sh "kubectl apply -f deployment/dev/be_hpa.yaml"
                 }
                }
                else if (env.BRANCH_NAME == 'staging') {
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                        sh "kubectl apply -f deployment/dev/configmap.yaml"
                        sh 'cat deployment/dev/be_app.yaml | sed "s/{{NEW_TAG}}/$GIT_COMMIT_SHORT-staging/g" |  kubectl apply -f -'
                        sh 'cat deployment/dev/fe_app.yaml | sed "s/{{NEW_TAG}}/$GIT_COMMIT_SHORT-staging/g" |  kubectl apply -f -'
                        sh "kubectl apply -f deployment/staging/be_hpa.yaml"
                 }
                }
                else if (env.BRANCH_NAME == 'main') {
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', serverUrl: '') {
                       sh "kubectl apply -f deployment/dev/configmap.yaml"
                        sh 'cat deployment/dev/be_app.yaml | sed "s/{{NEW_TAG}}/$GIT_COMMIT_SHORT-production/g" |  kubectl apply -f -'
                        sh 'cat deployment/dev/fe_app.yaml | sed "s/{{NEW_TAG}}/$GIT_COMMIT_SHORT-production/g" |  kubectl apply -f -'
                        sh "kubectl apply -f deployment/prod/be_hpa.yaml"
                 }
                }
                else {
                    sh 'echo Nothing to deploy'
                }
        }
      }
    } 
}

// if (env.BRANCH_NAME == 'dev' || env.BRANCH_NAME == 'staging' || env.BRANCH_NAME == 'prod' ) {
//      post {
//             success {
//                 slackSend channel: '#jenkins',
//                 color: 'good',
//                 message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}"
//             }    

//             failure {
//                 slackSend channel: '#jenkins',
//                 color: 'danger',
//                 message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}"
//                 }

//         }
     
//     }
        
}

