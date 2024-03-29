#!/usr/bin/env groovy
def image, name, variables

pipeline {
  agent { label 'docker' }

  options {
    timeout(time: 90, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '5'))
    disableConcurrentBuilds()
    ansiColor('xterm')
    timestamps()
  }

  triggers { cron '@daily' }

  parameters {
    string(defaultValue: "--exclude iota" , description: 'Robot arguments', name: 'ROBOT_ARGS')
  }

  environment {
    ROBOT_ARGS = "${params.ROBOT_ARGS}"
    TS_IMAGE_TAG="${env.GIT_BRANCH}-latest"
    ARGUS_IMAGE_TAG="${env.GIT_BRANCH}-latest"
  }

  stages {
    stage ('run'){
      steps {
        script {
          sh returnStatus: true, script: '''#!/bin/bash 
          set -ex
          cd compose
          docker-compose up trust
          docker-compose up --detach argus testsuite
          docker-compose exec -T --workdir /scripts argus bash /scripts/setup-argus.sh
          docker-compose exec -T --workdir /scripts argus bash /scripts/start-argus.sh
          docker-compose exec -T testsuite bash /scripts/ci-run-testsuite.sh
          '''
        }
      }
    }
  }

  post {
    always {
      sh '''#!/bin/bash
      set -ex
      output='./output'
      rm -rfv $output
      mkdir -p $output/argus_logs $output/argus_conf $output/argus_reports
      docker cp argus-testsuite_argus_1:/var/log/argus/ $output/argus_logs
      docker cp argus-testsuite_argus_1:/etc/argus/ $output/argus_conf
      docker cp argus-testsuite:/tmp/reports $output/argus_reports
      cd compose
      docker-compose down -v
      '''
      archiveArtifacts 'output/**'
      step([$class: 'RobotPublisher',
        disableArchiveOutput: false,
        logFileName: 'log.html',
        otherFiles: '*.png',
        outputFileName: 'output.xml',
        outputPath: "output/argus_reports/reports",
        passThreshold: 100,
        reportFileName: 'report.html',
        unstableThreshold: 90])
    }

    cleanup{
        cleanWs()
    }

    failure {
      slackSend color: 'danger', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Failure (<${env.BUILD_URL}|Open>)"
    }

    changed {
      script{
        if('SUCCESS'.equals(currentBuild.currentResult)) {
          slackSend color: 'good', message: "${env.JOB_NAME} - #${env.BUILD_NUMBER} Back to normal (<${env.BUILD_URL}|Open>)"
        }
      }
    }
  }
}
