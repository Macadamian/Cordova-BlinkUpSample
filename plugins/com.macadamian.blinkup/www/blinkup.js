/*global cordova, module*/

module.exports = {
    //API key is a string, timeoutMs is an int
    initiateBlinkUp: function (apiKey, timeoutMs, useCachedPlanId, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "BlinkUp", "initiateBlinkUp", [apiKey, timeoutMs, useCachedPlanId]);
    }
};
