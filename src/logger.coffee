# Logs the command result to the terminal, and applies colors to indicate
# whether the command ran successfully or not.
#
#     @name                   {String}
#     @args                   {String}
#     @result                 {Object}
#
logger = (name, args, result) ->
  if result.exitCode is 0
    console.log result.stdout.green
    console.log "✔ #{args}".green
  else
    console.log result.stderr.red
    console.log "✘ #{args}".red

# Attaches the public API function for the module
#
#     @libs                   {Object}
#
attach = (libs) ->
  libs.logger = logger

# Expose the attach function
module.exports = attach