# Module dependencies
sshclient   = require 'sshclient'
fs          = require 'fs'
_           = require 'underscore'
colors      = require 'colors'

# This creates the deployment paths
# for the app, based on user options
setDeploymentPaths = (options, cb) ->
  try
    timestamp             = Date.now().toString()
    basePath              = "#{options.baseDir}#{options.appName}/"
    deploymentsPath       = "#{basePath}deployments/"
    currentFolder         = "#{basePath}current/"
    outputFolder          = "#{deploymentsPath}#{timestamp}"
    cb null, {timestamp, basePath, deploymentsPath, currentFolder, outputFolder}
  catch err
    console.log err
    cb err, null

insertkeywordVariables = (commands, paths, options) ->
  return _.map commands, (cmd) ->
    return cmd
      .replace('OUTPUT_PATH',paths.outputFolder)
      .replace('CURRENT_PATH',paths.currentFolder)
      .replace('BASE_PATH',paths.basePath)
      .replace('DEPLOYMENTS_PATH',paths.deploymentsPath)
      .replace('TIMESTAMP',paths.timeStamp)
      .replace('GIT_REPO', options.repo)
      .replace('INSTALL_COMMAND', options.commands.install)
      .replace('RESTART_COMMAND', options.commands.restart)
      .replace('START_COMMAND', options.commands.start)

# We could move this into the configuration file

coldSetupCommands = [
  "mkdir BASE_PATH",
  "mkdir DEPLOYMENTS_PATH"
]

installCommands = [
  "git clone GIT_REPO OUTPUT_PATH",
  "cd OUTPUT_PATH && INSTALL_COMMAND"
]

startCommands = [
  "cd BASE_PATH && ln -s OUTPUT_PATH current",
  "cd CURRENT_PATH && START_COMMAND"
]

restartCommands = [
  "cd BASE_PATH && ln -sfn OUTPUT_PATH current",
  "cd CURRENT_PATH && RESTART_COMMAND"
]

displayResult = (command, exitCode, stderr) ->
  if exitCode is 0
    console.log "✔ #{command}".green
  else
    console.log "✘ #{command}".red
    console.log stderr.red

handleResult = (exitCode, number, commands, ssh, self, stderr, cb) ->
  if exitCode is 0 and number < commands.length-1
    executeTheNextCommand self, ssh, commands, number, cb
  else
    handleError stderr, exitCode, cb

executeTheNextCommand = (self, ssh, commands, number, cb) ->
  number++
  self.runCommand ssh, commands, number, cb

handleError = (stderr, exitCode, cb) ->
  err = new Error stderr if exitCode is 1
  cb err if typeof cb is 'function'  

launch = (ssh, options, preProcessedCommands, self, cb) ->
  setDeploymentPaths options, (err, paths) ->
    commands              = insertkeywordVariables preProcessedCommands, paths, options
    self.runCommands ssh, commands, cb

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
    preProcessedCommands  = _.union coldSetupCommands, installCommands, startCommands
    launch ssh, options, preProcessedCommands, @, cb

  # This runs a deployment of the application into a time-stamped folder
  update: (ssh, options, cb) ->
    preProcessedCommands  = _.union installCommands, options.commands.afterInstall, restartCommands
    launch ssh, options, preProcessedCommands, @, cb

  runCommands: (ssh, commands, cb) ->
    currentCommandNumber = 0
    @runCommand ssh, commands, currentCommandNumber, (err) ->
      cb err if typeof cb is 'function' 

  runCommand: (ssh, commands, number, cb) ->
    ssh.command commands[number], (procResult) =>
      displayResult commands[number], procResult.exitCode, procResult.stderr
      handleResult procResult.exitCode, number, commands, ssh, @, procResult.stderr, cb