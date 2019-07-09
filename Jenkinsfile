pipeline {
  agent {
    dockerfile {
      additionalBuildArgs '--build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
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
        script {
          try {
            sh '''
              make ganache
            '''
          } catch (Exception e) {
            echo "Error detected, trying to continue.."
          }
        }
      }
    }
    stage('Build OpenZeppelin-Solidity') {
      steps {
        script {
          try {
            sh '''
              make erc20
              cd ./deps/openzeppelin-solidity
              node node_modules/.bin/truffle compile
            '''
          } catch (Exception e) {
            echo "Error detected, trying to continue.."
          }
        }
      }
    }
    stage('Launch KEVM-VM') {
      steps {
        sh '''
          ./deps/evm-semantics/.build/defn/vm/kevm-vm 8080 127.0.0.1 &
        '''
      }
    }
    stage('Launch Ganache-CLI') {
      steps {
        sh '''
          node ./deps/ganache-cli/cli.js &
        '''
      }
    }
    stage('Run Truffle Test') {
      steps {
        sh '''
          cd ./deps/openzeppelin-solidity
          node node_modules/.bin/truffle test test/token/ERC20/ERC20.test.js
        '''
      }
    }
  }
}
