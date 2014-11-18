![Redstone](https://raw.github.com/axisto-live/redstone/master/redstone.png)

[![Codacy Badge](https://www.codacy.com/project/badge/f27c4fcb42544caab91fe4a506a6df3f)](https://www.codacy.com)

A tool for remotely executing scripts on servers, such as deploying apps.

This library began as a tool for deploying Node.js applications, heavily influenced by Capistrano. Over time, we realised that we could abstract away the commands that we used to deploy our web applications, leaving us a tool that could run any commands we pleased. 

Installation
---

    npm install redstone

Usage (via Node)
---

```javascript
    var Redstone = require("redstone");

    var config = {
      ssh: {
        hostname   : "myappserver.com",
        user 	     : "admin"
      }, 
      commands: {
        list_files: "ls -ll",
        print_date: "date"
        
      }
    };
    
    var redstone = new Redstone(config);
```

Running commands
---

To run a given command, execute it by typing it's name, then a callback to handle any errors

```javascript
    redstone.list_files(function(err){
      console.log(err);
    });
```

To run a list of commands in order, provide an array of commands, then a callback function to handle any errors

```javascript
    var commandsToRun = ['print_date', 'list_files'];
    redstone.runCommands(commandsToRun, function(err){
      console.log(err);
    });
```

License
---

&copy; 2014 Axisto Media Ltd. Redstone is licensed under the BSD License.
