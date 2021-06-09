var exec = require('cordova/exec');
var PLUGIN_NAME = 'DFNAppleWallet';

var executeCallback = function(callback, message) {
    if (typeof callback === 'function') {
        callback(message);
    }
};

var DFNAppleWallet = {
    addPass: function(reference, iban, account, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, PLUGIN_NAME, 'addPass', [reference, iban, account]);
        });
    }
};

module.exports = DFNAppleWallet;