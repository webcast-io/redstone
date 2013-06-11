assert = require 'assert'

describe "handler", ->

  it "should execute a command"

  describe "when successful", ->

    describe "and the command is the last in the list", ->

      it "should execute the callback, with a null error"

    describe "and the command is not the last in the list", ->

      it "should queue the next command for execution"

  describe "when not successful", ->

    it "should execute the callback, with the result's standard error output as the error"