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
    stage('Download Latest KEVM-VM Release') {
      steps {
        sh '''
          jq_query='[.[] | select(any(.tag_name; test("^v1.0.0-*")))][0]'  # select released tags
          jq_query="$jq_query"' | .assets[]'                               # browse packages
          jq_query="$jq_query"' | select(any(.label; test("Ubuntu *")))'   # select Debian package
          jq_query="$jq_query"' | .browser_download_url'                   # get download url
          release_url="$(curl 'https://api.github.com/repos/kframework/evm-semantics/releases' | jq --raw-output "$jq_query")"
          curl --location "$release_url" --output kevm_1.0.0_amd64.deb
          sudo apt-get update && sudo apt-get upgrade --yes && sudo apt-get install --yes ./kevm_1.0.0_amd64.deb
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
    stage('Launch & Run') {
      stages {
        stage('Run OpenZeppelin-Solidity') {
          steps {
            sh '''
              runtest.sh $(sed -n 1p tests.txt)
            '''
          }
        }
        stage('Run Archanova-Abridged') {
          steps {
            sh '''
              runtest.sh $(sed -n 2p tests.txt)
            '''
          }
        }
      }
    }
  }
}
