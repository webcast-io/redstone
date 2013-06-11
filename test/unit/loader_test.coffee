assert = require 'assert'
loader = require '../../src/loader'

describe "loader", ->

  before (done) ->
    # Context in this case is an instance of the Redstone class
    # which we're mocking, as we don't want to execute any
    # real ssh commands in the unit test
    @ctx = 
      ssh: 
        command: (args, cb) -> 
          # this is a mock of calling the ssh command
          result = 
            exitCode  : 0
            stdout    : "This is standard output"
            stderr    : null
          cb result
      # We mock the logger in this unit test 
      libs:
        logger: (name, args, result) -> {}
    done()

  it "should bind a function with a given name to the context", (done) ->
    loader @ctx.libs
    @ctx.libs.loader @ctx, 'list_files', 'll_ll'
    assert.notEqual undefined, @ctx.list_files
    @ctx.list_files (result) ->
      assert.equal 0, result.exitCode
      assert.equal "This is standard output", result.stdout
      assert.equal null, result.stderr
      done()