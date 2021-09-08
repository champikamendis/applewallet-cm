var exec = require('cordova/exec');
var PLUGIN_NAME = 'DFNAppleWallet';

var DFNAppleWallet = {
    addPass: function(passEndpoint, jsonValue, successCallback, errorCallback) {
        exec(successCallback, errorCallback, PLUGIN_NAME, 'addPass', [passEndpoint, jsonValue]);
    },

    contains: function(passEndpoint, jsonValue, successCallback, errorCallback) {
        exec(successCallback, errorCallback, PLUGIN_NAME, 'contains', [passEndpoint, jsonValue]);
    },
};

module.exports = DFNAppleWallet;

