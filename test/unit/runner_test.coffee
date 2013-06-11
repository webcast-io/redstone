assert  = require 'assert'
runner  = require '../../src/runner'
handler = require '../../src/handler'
logger  = require '../../src/logger'
loader  = require '../../src/loader'

describe "runner", ->

  before (done) ->
    @ctx =
      ssh: 
        command: (args, cb) -> 
          # this is a mock of calling the ssh command
          result = 
            exitCode  : 0
            stdout    : "This is standard output"
            stderr    : null
          cb result
      libs: {}
    runner @ctx.libs
    handler @ctx.libs
    logger @ctx.libs
    loader @ctx.libs
    @ctx.libs.loader @ctx, 'list_files', 'ls -ll'
    done()

  describe "runCommand", ->

    it "should run a single command, and execute the callback", (done) ->
      currentCommandNumber  = 0
      @ctx.libs.runner.runCommand @ctx, ['list_files'], currentCommandNumber, (err) ->
        assert.equal null, err
        done()

  describe "runCommands", ->

    it "should run a list of commands, in sequential order"