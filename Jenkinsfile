pipeline {
  agent {
    dockerfile {
      additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
      dir 'deps/evm-semantics'
    }
  }
  options {
    ansiColor('xterm')
  }
  stages {
    stage("Init title") {
      when { changeRequest() }
      steps {
        script {
          currentBuild.displayName = "PR ${env.CHANGE_ID}: ${env.CHANGE_TITLE}"
        }
      }
    }
    stage('Dependencies') {
      steps {
        sh '''
          make deps
        '''
      }
    }
    stage('Build LLVM Node') {
        steps {
        sh '''
            make rust
            make build-kevm-node
        '''
        }
    }
    stage('Build Ganache with KEVM-VM') {
        steps {
            sh '''
                make ganache
            '''
        }
    }
    stage('Build OpenZeppelin-Solidity') {
        steps {
            sh '''
                make erc20
                '''
        }
    }
    stage('Total Supply test') {
        steps {
            sh '''
                node runtest.js
            '''
        }
    }
  }
}
