const cp = require('child_process')
const resolve = require('path').resolve
const tcpPortUsed = require('tcp-port-used')

const kevmPath = resolve('deps/evm-semantics/.build/defn/vm/kevm-vm')
const trufflePath = resolve('../../openzeppelin-solidity/node_modules/.bin/truffle') //resolve('deps/openzeppelin-solidity/node_modules/.bin/truffle')
const testPath = resolve('../../openzeppelin-solidity/transfer.js') //resolve ('deps/openzeppelin-solidity/test/token/ERC20/ERC20.test.js')
const cliPath = resolve('../ganache-cli/cli.js') //resolve('deps/ganache-cli/cli.js')

const retryTimeMs = 500
const timeOutMs = 4000
const kevmPort = 8080
const kevmHost = '127.0.0.1'

console.log(trufflePath)
console.log(testPath)
console.log(cliPath)
console.log(kevmPath, kevmPort, kevmHost)

var kevmChild = cp.spawn(kevmPath, [kevmPort, kevmHost])

kevmChild.on('exit', function (code, signal) {
    console.log('kevm exiting with code', code)
    if('SIGTERM' !== signal || false === dataReceived){
      process.exit(1)
    }
    process.exit()
})

tcpPortUsed.waitUntilUsed(kevmPort, retryTimeMs, timeOutMs)
.then(function () {
    process.chdir(resolve('../../openzeppelin-solidity'));
    console.log('spawn CLI')
    var cliChild = cp.spawn(cliPath,[])
    console.log('spawn Truffle')
    var truffleChild = cp.spawn(trufflePath,['test', testPath])
    
    truffleChild.on('exit', function (code, signal) {
        kevmChild.kill()
        cliChild.kill()
        console.log('truffle exiting with code', code)
        if('SIGTERM' !== signal || false === dataReceived){
          process.exit(1)
        }
        process.exit()
    })

    truffleChild.stdout.on('data', function(data) {
        console.log('truffle', data.toString()); 
    });

    truffleChild.stderr.on('data', (data) => console.log('truffle',data.toString()))
    cliChild.stderr.on('data', (data) => console.log('cli',data.toString()))
    cliChild.stdout.on('data', (data) => console.log('cli',data.toString()))

    cliChild.on('exit', function (code, signal) {
        kevmChild.kill()
        truffleChild.kill()
        console.log('cli exiting with code', code)
        if('SIGTERM' !== signal || false === dataReceived){
          process.exit(1)
        }
        process.exit()
    })
}, function(err) {
    console.log('Error:', err.message)
    process.exit(1)
})