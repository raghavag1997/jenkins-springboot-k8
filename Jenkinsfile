pipeline {
  agent any

  stages {
      stage('Pulling the code from Repo') {
          steps {
              git branch: 'main', url: 'https://github.com/raghavag1997/jenkins-springboot-k8.git'
          }
      }
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('Unit Test and Jacoco(Code Coverage)') {
          steps {
              sh 'mvn test'
          }
          post {
              always {
                 //Requires junit and jacoco Plugin should be Installed
                 junit 'target/surefire-reports/*.xml'
                 jacoco execPattern: 'target/jacoco.exe'
              }
          }
      } 
      stage('Bulding Docker Image') {
          steps {
              sh 'docker build -t ragh19/springboot:$BUILD_NUMBER .'
          }
      }
      stage('Publishing Docker Image') {
          steps {
              withDockerRegistry(credentialsId: 'dockerhub') {
                  sh 'docker push ragh19/springboot:$BUILD_NUMBER'
                  
            }
          }
      }
      stage('Deploying to kubernetes') {
          steps {
              withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: '0e4ff84e-9367-46d6-8be4-b65a31291bdc', namespace: '', serverUrl: '') {
                //Replacing Image Name With latest Image
                sh 'sed -i "s,replace,ragh19/springboot:$BUILD_NUMBER," k8s_deployment_service.yaml'              
                //Applying the latest Image
                sh 'kubectl apply -f k8s_deployment_service.yaml'              
                //List the pod
                sh 'kubectl get pods'  
            }
          }
      }
    }
}
