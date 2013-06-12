assert = require 'assert'
logger = require '../../src/logger'

describe "logger", ->

  before (done) ->
    # Context in this case is an instance of the Redstone class
    # which we're mocking, as we don't want to execute any
    # real ssh commands in the unit test
    @ctx =
      libs: {}
    done()  

  it "should log out the result, and use different colors depending on the status", (done) ->
    mockResult = 
      exitCode: 0
      stdout: "This is some output"
      stderr: null
    logger @ctx.libs    
    @ctx.libs.logger "list_files", "ls -ll", mockResult
    err = new Error "have not completed all assertions here yet"
    done err