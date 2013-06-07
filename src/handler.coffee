# Handles an executed command's results
#
#     @commands               {Array}
#     @currentCommandNumber   {Number}
#     @result                 {Object}
#     @context                {Object}
#     @cb                     {Function}
#
handleResult = (commands, currentCommandNumber, result, context, cb) ->
    if result.exitCode is 0
      handleSuccess commands, currentCommandNumber, context, cb
    else
      handleFailure result.stderr, cb

# Handles an executed command that failed
#
#     @errStack               {String}
#     @cb                     {Function}
#
handleFailure = (errStack, cb) -> 
  cb new Error errStack

# Handles a successfully executed command
#
#     @commands               {Array}
#     @currentCommandNumber   {Number}
#     @context                {Object}
#     @cb                     {Function}
#
handleSuccess = (commands, currentCommandNumber, context, cb) ->
  if currentCommandNumber < commands.length-1
    currentCommandNumber++
    context.libs.runner.runCommand context, commands, currentCommandNumber, cb
  else
    cb null

# Attaches the public API function for the module
#
#     @libs                   {Object}
#
attach = (libs) ->
  libs.handler = handleResult

# Expose the attach function
module.exports = attach