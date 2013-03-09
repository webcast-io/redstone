var sshclient = require('sshclient')
  , fs        = require('fs');

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

    var commands = [
        "mkdir " + basePath
      , "mkdir " + deploymentsPath
      , 'git clone ' + options.repo + ' ' + outputFolder
      , 'cd ' + outputFolder + ' && ' + options.commands.install
      , 'cd ' + basePath + ' && ln -s ' + outputFolder + " current"
      , 'cd ' + currentFolder + ' && ' + options.commands.start
    ];

    this.runCommands(ssh, commands, cb);
  },

  update: function(ssh, options, cb) {
    var timeStamp       = Date.now().toString()
    var basePath        = options.baseDir + options.appName + "/";
    var deploymentsPath = basePath + "deployments/";
    var currentFolder   = basePath + "current/";
    var outputFolder    = deploymentsPath + timeStamp;

    var commands = [
        'git clone ' + options.repo + ' ' + outputFolder
      , 'cd ' + outputFolder + ' && ' + options.commands.install
      , 'cd ' + basePath + ' && ln -sfn ' + outputFolder + " current"
      , 'cd ' + currentFolder + ' && ' + options.commands.restart
    ];

    this.runCommands(ssh, commands, cb);
  },

  runCommands: function(ssh, commands, cb) {
    currentCommandNumber  = 0;
    this.runCommand(ssh, commands, currentCommandNumber ,function(err){
      cb(err);
    });
  },

  runCommand: function(ssh, commands, number, cb) {
    var err   = null;
    var self  = this;
    ssh.command(commands[number], function(procResult){
      if (procResult.exitCode == 0 && number < commands.length-1) {
        number++;
        self.runCommand(ssh, commands, number, cb);
      } else {
        if (procResult.exitCode == 1) {
          err = new Error(procResult.stderr);
        }
        cb(err);
      }
    });
  }

}