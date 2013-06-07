![Redstone](https://raw.github.com/axisto-live/redstone/master/redstone.png)

A tool for deploying Node.js applications, heavily influenced by Capistrano.

Installation
---

    npm install redstone

Usage (via Node)
---

    var Redstone = require("redstone");

    var config = {
      ssh: {
        hostname   : "myappserver.com"
        user 	   : "admin"
        port       : 22
      }, 
      commands: {
        list_files: "ls -ll"
      }
    };
    
    var redstone = new Redstone(config);
    redstone.
    

License
---

&copy; 2013 Axisto Media Ltd. Redstone is licensed under the BSD License.
