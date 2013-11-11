var args = require('system').args;
var fs = require('fs');
var page = require('webpage').create();

page.open(args[1], function () {
    setTimeout(function() {
    	fs.write(args[2], page.content, 'w');
    	phantom.exit();
    }, 5000);
});
