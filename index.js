var sshclient   = require('sshclient')
  , fs          = require('fs')
  , _           = require('underscore')
  , colors      = require('colors');

module.exports = {

  // SSH into a server, and return the server 
  // so that commands can be executed
  login: function(options, cb){

    var self = this;

    var ssh = new sshclient.SSH({
        hostname  : options.hostname
      , user      : options.user
      , port      : options.port
    });

    cb(ssh);
  },

  // This creates the folders that are needed to deploy the application
  coldSetup: function(ssh, options, cb) {
    var timeStamp       = Date.now().toString()
    var basePath        = options.baseDir + options.appName + "/";
    var deploymentsPath = basePath + "deployments/";
    var currentFolder   = basePath + "current/";
    var outputFolder    = deploymentsPath + timeStamp;

    var coldSetupCommands = [
        "mkdir " + basePath
      , "mkdir " + deploymentsPath
    ];

    var installCommands = [
        'git clone ' + options.repo + ' ' + outputFolder
      , 'cd ' + outputFolder + ' && ' + options.commands.install
    ];

    var restartCommands = [
        'cd ' + basePath + ' && ln -s ' + outputFolder + " current"
      , 'cd ' + currentFolder + ' && ' + options.commands.start
    ];

    var commands = _.union(coldSetupCommands, installCommands, restartCommands);

    this.runCommands(ssh, commands, cb);
  },

  update: function(ssh, options, cb) {
    var timeStamp       = Date.now().toString()
    var basePath        = options.baseDir + options.appName + "/";
    var deploymentsPath = basePath + "deployments/";
    var currentFolder   = basePath + "current/";
    var outputFolder    = deploymentsPath + timeStamp;

    var insertkeywordVariables = function(commands) {
      return _.map(commands, function(cmd){
        return cmd
          .replace('OUTPUT_PATH',outputFolder)
          .replace('CURRENT_PATH',currentFolder)
          .replace('BASE_PATH',basePath)
          .replace('DEPLOYMENTS_PATH',deploymentsPath)
          .replace('TIMESTAMP',timeStamp)
          .replace('GIT_REPO', options.repo);
      });
    }

    var installCommands = [
        'git clone GIT_REPO OUTPUT_PATH'
      , 'cd OUTPUT_PATH && ' + options.commands.install
    ];

    var restartCommands = [
        'cd BASE_PATH && ln -sfn OUTPUT_PATH current'
      , 'cd CURRENT_PATH && ' + options.commands.restart
    ];

    var commands = insertkeywordVariables(_.union(installCommands, options.commands.afterInstall, restartCommands));
    this.runCommands(ssh, commands, cb);
  },

  runCommands: function(ssh, commands, cb) {
    currentCommandNumber  = 0;
    this.runCommand(ssh, commands, currentCommandNumber ,function(err){
      if (typeof cb == 'function') { cb(err) };
    });
  },

  runCommand: function(ssh, commands, number, cb) {
    var err   = null;
    var self  = this;
    ssh.command(commands[number], function(procResult){
      if (procResult.exitCode == 0) {
        console.log(("✔ "+commands[number]).green);
      } else {
        console.log(("✘ "+commands[number]).red);
        console.log(procResult.stderr.red);
      };

      if (procResult.exitCode == 0 && number < commands.length-1) {
        number++;
        self.runCommand(ssh, commands, number, cb);
      } else {
        if (procResult.exitCode == 1) {
          err = new Error(procResult.stderr);
          if (typeof cb == 'function') { cb(err) };
        } else {
          if (typeof cb == 'function') { cb(err) };
        }
      }
    });
  }

}