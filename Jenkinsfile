pipeline {
    agent any
        parameters {
        string(name: 'VERSION', defaultValue: '1.0', description: 'Enter the version number')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'qa', 'prod'], description: 'Select the target environment')
        booleanParam(name: 'CLEAN_BUILD', defaultValue: true, description: 'Perform a clean build')
    }
    stages {
        stage('Build') {
            steps {
                echo "Selected branch: ${params.GIT_BRANCH}"
                // 在这里可以使用所选的分支执行构建操作
            }
        }
    }
}