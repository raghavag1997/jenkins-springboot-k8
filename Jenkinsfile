pipeline {
  agent any
  environment {
    repoName='ragh19/springboot'
    imageName="${repoName}:${BUILD_NUMBER}"
  }
  stages {
      stage('Pulling the code from Repo') {
          steps {
              git branch: 'main', url: 'https://github.com/raghavag1997/jenkins-springboot-k8.git'
          }
      }
      stage('SonarQube Analysis') {
          steps {
             withSonarQubeEnv('SonarQube') {
               sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=springboot-firstproject -Dsonar.host.url=http://52.253.114.17:9000'
             }  
          }
      }
    stage("Quality Gate") {
         steps {
              timeout(time: 1, unit: 'HOURS') {
               waitForQualityGate abortPipeline: true
              }
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
      stage('Docker Image Scan - Trivy and OPA DockerFile Best Prac') {
          steps {
              parallel(
                    "Trivy Scan": {
                      sh 'bash trivyscan.sh'
                    },
                    "OPA Conftest": {
                      sh 'sudo docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy docker-security.rego Dockerfile'
                  }
              )
          }
      }
      stage('Bulding Docker Image') {
          steps {
            sh 'sudo docker build -t ${imageName} .'
          }
      }
      stage('Publishing Docker Image') {
          steps {
              withDockerRegistry(credentialsId: 'dockerhub' , url: '') {
                  sh 'docker push ${imageName}'
                  
            }
          }
      }
//    stage('k8 Deployment File Scan - OPA') {
  //    steps {
    //    sh 'sudo docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy k8-security.rego k8s_deployment_service.yaml'
      //}
    //}
    stage('K8 Vul Scan - Kubesec') {
      steps {
        parallel (
          "kubescan": {
              sh 'bash kube-scan.sh'   
          },
          "TrivyScan": {
            sh 'bash trivyscan-k8.sh'
          }
        )
      }
    }
      stage('Deploying to kubernetes - Prod') {
          steps {
              withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: '0e4ff84e-9367-46d6-8be4-b65a31291bdc', namespace: 'prod', serverUrl: '') {
                //Replacing Image Name With latest Image
                sh 'sed -i "s,replace,ragh19/springboot:$BUILD_NUMBER," prod-k8/k8s_deployment_service.yaml'              
                //Applying the latest Image
                sh 'kubectl apply -f prod-k8/k8s_deployment_service.yaml'              
                //List the pod
                sh 'kubectl get pods'  
            }
          }
      }
    }
}
