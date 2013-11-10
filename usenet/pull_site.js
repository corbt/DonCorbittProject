var args = require('system').args;

var page = require('webpage').create();
page.open(args[1], function () {
    setTimeout(function() {
    	console.log(page.content);
    	phantom.exit();
    }, 5000);
    // return page.content;
});
