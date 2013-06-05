sshclient   = require 'sshclient'
fs          = require 'fs'
_           = require 'underscore'
colors      = require 'colors'

module.exports =

  # SSH into a server, and return the server 
  # so that commands can be executed
  login: (options, cb) ->
    ssh = new sshclient.SSH
      hostname  : options.hostname
      user      : options.user
      port      : options.port
    cb ssh

  # This creates the folders that are needed to deploy the application
  coldSetup: (ssh, options, cb) ->
    timeStamp       = Date.now().toString()
    basePath        = options.baseDir + options.appName + "/"
    deploymentsPath = basePath + "deployments/"
    currentFolder   = basePath + "current/"
    outputFolder    = deploymentsPath + timeStamp

    coldSetupCommands = [
      "mkdir #{basePath}",
      "mkdir #{deploymentsPath}"
    ]

    installCommands = [
      "git clone #{options.repo} #{outputFolder}",
      "cd #{outputFolder} && #{options.commands.install}"
    ]

    restartCommands = [
      "cd #{basePath} && ln -s #{outputFolder} current",
      "cd #{currentFolder} && #{options.commands.start}"
    ]

    commands = _.union coldSetupCommands, installCommands, restartCommands

    @runCommands ssh, commands, cb

  # This runs a deployment of the application into a time-stamped folder
  update: (ssh, options, cb) ->
    timeStamp       = Date.now().toString()
    basePath        = options.baseDir + options.appName + "/"
    deploymentsPath = basePath + "deployments/"
    currentFolder   = basePath + "current/"
    outputFolder    = deploymentsPath + timeStamp

    insertkeywordVariables = (commands) ->
      return _.map commands, (cmd) ->
        return cmd
          .replace('OUTPUT_PATH',outputFolder)
          .replace('CURRENT_PATH',currentFolder)
          .replace('BASE_PATH',basePath)
          .replace('DEPLOYMENTS_PATH',deploymentsPath)
          .replace('TIMESTAMP',timeStamp)
          .replace('GIT_REPO', options.repo);

    installCommands = [
      "git clone GIT_REPO OUTPUT_PATH",
      "cd OUTPUT_PATH && #{options.commands.install}"
    ]

    restartCommands = [
      "cd BASE_PATH && ln -sfn OUTPUT_PATH current",
      "cd CURRENT_PATH && #{options.commands.restart}"
    ]

    commands = insertkeywordVariables _.union installCommands, options.commands.afterInstall, restartCommands
    @runCommands ssh, commands, cb

  runCommands: (ssh, commands, cb) ->
    currentCommandNumber = 0
    @runCommand ssh, commands, currentCommandNumber, (err) ->
      cb err if typeof cb is 'function' 

  runCommand: (ssh, commands, number, cb) ->
    err   = null
    self  = @
    ssh.command commands[number], (procResult) ->
      if procResult.exitCode is 0
        console.log "✔ #{commands[number]}".green
      else
        console.log "✘ #{commands[number]}".red
        console.log procResult.stderr.red

      if procResult.exitCode is 0 and number < commands.length-1
        number++
        self.runCommand ssh, commands, number, cb
      else
        err = new Error procResult.stderr if procResult.exitCode is 1
        cb err if typeof cb is 'function'