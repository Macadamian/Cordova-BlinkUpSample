cordova.define("com.macadamian.blinkup.blinkup", function(require, exports, module) { /*global cordova, module*/

module.exports = {
    invokeBlinkUp: function (apiKey, timeoutMs, useCachedPlanId, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "BlinkUpPlugin", "invokeBlinkUp", [apiKey, timeoutMs, useCachedPlanId]);
    }
};

});
