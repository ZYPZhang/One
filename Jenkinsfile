pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo "Selected branch: ${params.GIT_BRANCH}"
        sh 'echo "hello"'
      }
    }

    stage('123') {
      steps {
        echo '111'
      }
    }

  }
}