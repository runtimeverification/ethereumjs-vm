const ERROR = {
  OUT_OF_GAS: 'out of gas',
  STACK_UNDERFLOW: 'stack underflow',
  STACK_OVERFLOW: 'stack overflow',
  INVALID_JUMP: 'invalid JUMP',
  INVALID_OPCODE: 'invalid opcode',
  OUT_OF_RANGE: 'value out of range',
  REVERT: 'revert',
  STATIC_STATE_CHANGE: 'static state change',
  INTERNAL_ERROR: 'internal error'
}

function getExceptionType (statusCode) {
  switch (statusCode) {
    // SUCCESS CASE, should never be hit
    case (new Uint8Array([200,4,0,0,2,0,128,1,160,159,65,0,0,0,0,0])): {
      return ''
      break
    }
    default : {
      return ERROR.REVERT
      break
    }
  }
}

function VmError (error) {
  this.error = error
  this.errorType = 'VmError'
}

module.exports = {
  ERROR: ERROR,
  VmError: VmError,
  getExceptionType: getExceptionType
}
