pipeline {
  agent {
    dockerfile {
      additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
    }
  }
  options {
    ansiColor('xterm')
  }
  environment {
    FIREFLY_DEBUG = 'true'
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
    stage('Run Linter') {
      steps {
        sh '''
          npm run lint
        '''
      }
    }
    stage('Build OpenZeppelin-Solidity') {
      steps {
        sh '''
          make erc20
          cd ./deps/openzeppelin-solidity
          node node_modules/.bin/truffle compile
        '''
      }
    }
    stage('Launch & Run') {
      steps {
        sh '''
          make start-vm
          make test-openzeppelin
          make stop-vm
        '''
      }
    }
  }
}
