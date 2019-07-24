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
          truffle compile
        '''
      }
    }
    stage('Launch & Run') {
      steps {
        sh '''
          export PATH="$PATH:${WORKSPACE}/deps/evm-semantics/.build/defn/vm"
          node ./deps/ganache-cli/cli.js --gasLimit 0xfffffffffff --port 8545 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501201,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501202,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501203,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501204,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501205,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501206,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501207,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208,1000000000000000000000000 --account=0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501209,1000000000000000000000000 &
          cd ./deps/openzeppelin-solidity
          truffle test
          pkill node
          pkill kevm-vm
        '''
      }
    }
  }
}
