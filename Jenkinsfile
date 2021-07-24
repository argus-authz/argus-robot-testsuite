pipeline {

  agent { label 'docker' }

  options {
    timeout(time: 3, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }

  stages {
    stage('build image') {
      steps {
        script {
          dir('docker/testsuite') {
            sh './build-image.sh'           
          }
          dir('docker/all-in-one-centos7') {
            sh './build-image.sh'           
          }
        }
      }
    }

    stage('push-dockerhub') {
      steps {
        script {
          withDockerRegistry([ credentialsId: "dockerhub-enrico", url: "" ]) {
            dir('docker/testsuite') {
              sh './push-image.sh'
            }
            dir('docker/all-in-one-centos7') {
              sh './push-image.sh'
            }
          }
        }
      }
    }
    
    stage('result') {
      steps {
        script {
          currentBuild.result = 'SUCCESS'
        }
      }
    }
  }

  post {
    failure {
      slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Failure (<${env.BUILD_URL}|Open>)"
    }

    changed {
      script {
        if ('SUCCESS'.equals(currentBuild.result)) {
          slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
        }
      }
    }
  }
}

