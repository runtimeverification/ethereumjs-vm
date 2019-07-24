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
    stage('Install Truffle') {
      steps {
        sh '''
          make truffle
        '''
      }
    }
    stage('Launch & Run') {
      stages {
        stage('Run OpenZeppelin-Solidity') {
          steps {
            sh '''
              git clone https://github.com/openzeppelin/openzeppelin-solidity.git
              cd openzeppelin-solidity && npm install
              cd .. && make start-vm CLIARGS="--gasLimit 0xfffffffffff --port 8545 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501201,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501202,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501203,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501204,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501205,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501206,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501207,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501209,1000000000000000000000000"
              cd openzeppelin-solidity && truffle test
              cd .. && make stop-vm
            '''
          }
        }
        stage('Run Archanova-Abridged') {
          steps {
            sh '''
              git clone https://github.com/netgum/archanova-contracts.git
              cd archanova-contracts && npm install
              cd .. && make start-vm CLIARGS="-p 8555 --gasLimit 0xfffffffffff -e 1000000"
              cd archanova-contracts && truffle test
              cd .. && make stop-vm
            '''
          }
        }
      }
    }
  }
}
