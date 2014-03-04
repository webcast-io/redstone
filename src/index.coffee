sshclient = require 'node-sshclient'

# Create an object for loading modules that require each other.
# This avoids a chicken-egg problem when decoupling modules
# that depend upon each other.
libs = {}
require('./logger') libs
require('./loader') libs
require('./runner') libs
require('./handler') libs

class Redstone

  # Called when a new instance of the Redstone class is instantiated with.
  # This creates a new ssh client, and loads the commands that the ssh client
  # can execute.
  # 
  #     @options                {Object}
  #
  constructor: (@options) ->
    @ssh  = new sshclient.SSH @options.ssh
    @libs = libs
    @libs.loader @, name, args for name,args of @options.commands

  # Runs a list of commands in sequential order, then executes a callback
  # function, if one is provided
  #
  #     @commands               {Array}
  #     @cb                     {Function}
  #
  runCommands: (commands, cb) ->
    @libs.runner.runCommands @, commands, cb

# Expose the Redstone class as the public API
module.exports = Redstone