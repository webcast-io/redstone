# This adds commands into the instance so that the ssh client can execute them
#
#     @context                {Object}        
#     @name                   {String}
#     @args                   {String}
#
loader = (context, name, args) ->
  context[name] = (cb) =>
    context.ssh.command args, (result) =>
      context.libs.logger name, args, result
      cb result

# Attaches the public API function for the module
#
#     @libs                   {Object}
#
attach = (libs) ->
  libs.loader = loader

# Expose the attach function
module.exports = attach