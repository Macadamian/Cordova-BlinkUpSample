/*global cordova, module*/

module.exports = {
    //API key is a string, timeoutMs is an int
    invokeBlinkUp: function (apiKey, timeoutMs, useCachedPlanId, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "BlinkUpPlugin", "invokeBlinkUp", [apiKey, timeoutMs, useCachedPlanId]);
    }
};
