pipeline {  
    environment {
         imagename = "quote-stub"
     }

    agent any
    stages {
       stage('Build') { 
            steps {
                script {
                    docker.build imagename
                }
            }
       }  
       stage('Deliver') {
            steps{ 
                sh '/push2dockerhub.sh $imagename'
            }
       }
       stage('Deploy') {
            steps{ 
                sh '/push2iks.sh stock-trader quote-stub quote-stub-pod.yaml'
            }
       }
    }
}