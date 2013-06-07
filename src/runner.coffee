# Runs a list of commands in sequential order, then executes a callback
# function, if one is provided
#
#     @context                {Object}
#     @commands               {Array}
#     @cb                     {Function}
#
runCommands = (context, commands, cb) ->
  currentCommandNumber = 0
  runCommand context, commands, currentCommandNumber, (err) ->
    cb err if typeof cb is 'function' 

# Runs a given command, and delegates the command result to the handler
#
#     @context                {Object}
#     @commands               {Array}
#     @currentCommandNumber   {Number}
#     @cb                     {Function}
#
runCommand = (context, commands, currentCommandNumber, cb) ->
  commandToRun = commands[currentCommandNumber]
  context[commandToRun] (result) ->
    context.libs.handler commands, currentCommandNumber, result, context, cb

# Attaches the public API function for the module
#
#     @libs                   {Object}
#
attach = (libs) ->
  libs.runner = {runCommands, runCommand}

# Expose the attach function
module.exports = attach