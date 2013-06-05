![Redstone](https://raw.github.com/axisto-live/redstone/master/redstone.png)

A tool for deploying Node.js applications, heavily influenced by Capistrano.

Installation
---

    npm install redstone

Usage
---

At the moment, redstone is required programmatically, but a CLI option will be added soon.

    var redstone = require('redstone');

    var options = {
        appName     : "YOUR-APP-NAME"
      , repo        : "git@github.com:ACCOUNT/REPO.git"
      , user        : "root"
      , publicKey   : "PATH_TO/PUBLIC_KEY"
      , hostname    : "IP_ADDRESS"
      , port        : PORT_NUMBER
      , baseDir     : "PATH_TO_DIR_WHERE_APP_FILES_WILL_EXIST"
      , commands    : {
          install : "COMMAND_TO_INSTALL_DEPENDENCIES"
        , start   : "COMMAND_TO_START_APP"
        , stop    : "COMMAND_TO_STOP_APP"
        , restart : "COMMAND_TO_RESTART_APP"
      }
    };


    // To run a first-time setup of the app
    // on your server:
    redstone.login(options, function(ssh){
      redstone.coldSetup(ssh, options, function(err){
      });
    });

    // To deploy an update of your app to
    // the server:
    redstone.login(options, function(ssh){
      redstone.update(ssh, options, function(err){
      });
    });

License
---

&copy; 2013 Axisto Media Ltd. Redstone is licensed under the BSD License.
