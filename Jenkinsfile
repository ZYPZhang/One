// pipeline {
//     agent any
//     parameters {
//         choice(
//             name: 'GIT_BRANCH',
//             choices: gitBranches(),
//             description: 'Select the Git branch'
//         )
//     }
//     stages {
//         stage('Build') {
//             steps {
//                 echo "Selected branch: ${params.GIT_BRANCH}"
//                 // 在这里可以使用所选的分支执行构建操作
//             }
//         }
//     }
// }

// def gitBranches() {
//     // 使用 `git` 命令获取远程仓库的分支列表，并解析为字符串数组
//     return sh(
//         script: 'git ls-remote --heads origin | awk -F/ \'{print $NF}\'',
//         returnStdout: true
//     ).trim().split('\n')
// }

pipeline {
    agent any
    stages {
        stage('Example') {
            agent {
                // 指定在具有该工作区的节点上运行
                node('master') {
                    // 在该节点上的工作区中执行步骤
                    workspace {
                        // 在工作区中执行操作，包括使用 hudson.FilePath 方法
                        steps {
                            sh 'echo "Working directory: ${pwd()}"'
                            script {
                                // 在这里使用 hudson.FilePath 方法
                                def filePath = pwd()
                                filePath.listFiles().each { file ->
                                    println "File: ${file.name}"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}