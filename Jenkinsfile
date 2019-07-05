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
    stage('Build KEVM-VM') {
        steps {
        sh '''
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
    stage('Launch KEVM-VM') {
      steps {
          sh '''
              make start-kevm
          '''
      }
    }
    stage('Launch Ganache-CLI') {
      steps {
          sh '''
              make start-ganache
          '''
      }
    }
    stage('Run Truffle Test') {
        steps {
            sh '''
                make start-truffle-test
            '''
        }
    }
  }
}
