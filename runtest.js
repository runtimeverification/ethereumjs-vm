const cp = require('child_process')
const resolve = require('path').resolve
const tcpPortUsed = require('tcp-port-used')

const kevmPath = resolve('deps/evm-semantics/.build/defn/vm/kevm-vm')
const trufflePath = resolve('deps/openzeppelin-solidity/node_modules/.bin/truffle')
const testPath = resolve('deps/openzeppelin-solidity/totalSupply.js')
const cliPath = resolve('deps/ganache-cli/cli.js')

const retryTimeMs = 500
const timeOutMs = 4000
const kevmPort = 8080
const kevmHost = '127.0.0.1'

console.log('Truffle Path: ', trufflePath)
console.log('Test Path: ', testPath)
console.log('Ganahce-cli Path:', cliPath)
console.log('KEVM-VM Path: ', kevmPath)

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

    var cmd ='node ' + cliPath + ' & sleep 5s ; ' + trufflePath + ' test ' + testPath
    console.log(cmd)
    child = cp.exec(cmd)
    child.on('exit', function (code, signal) {
        kevmChild.kill()
        if('SIGTERM' !== signal || false === dataReceived){
          process.exit(1)
        }
        process.exit()
    })

    child.stderr.on('data', (data) => console.log(data.toString()))
    child.stdout.on('data', (data) => console.log(data.toString()))

}, function(err) {
    console.log('Error:', err.message)
    process.exit(1)
})