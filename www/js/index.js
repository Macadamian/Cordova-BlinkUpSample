/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 * Modified by Stuart Douglas (sdouglas@macadamian.com) on June 11, 2015
 */

/*global blinkup, errorMessageForCode, statusMessageForCode*/

/******************************************************************
 * IMPORTANT NOTE: Changing the following 3 values in either:     *
 * Cordova-BlinkUpSample/platforms/ios/www/js/index.js OR         *
 * Cordova-BlinkUpSample/platforms/android/assets/www/js/index.js *
 * won't change anything. The values are overwritten at build     *
 * time by those in Cordova-BlinkUpSample/www/js/index.js.        *
 ******************************************************************/
 var apiKey = "";       // this MUST be set or the app won't work
 var planId = "";       // if blank, SDK will generate a planId
 var timeoutMs = 60000; // default is 60s
//=================================================================

var interval;

var app = {
    // Application Constructor
    initialize: function () {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function () {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function () {
        app.receivedEvent('deviceready');

        var btn = document.getElementById('blinkup-button');
        btn.addEventListener('click', function () {

            var success = function (message) {
                var jsonData;
                try {
                    jsonData = JSON.parse(message);
                    this.updateInfo(jsonData);
                    if (jsonData.state === "started") {
                        this.startProgress();
                    } else {
                        this.endProgress();
                    }
                } catch (exception) {
                    console.log("Error parsing JSON in success callback:" + exception);
                    console.log(message);
                    this.endProgress();
                }
            };

            var failure = function (message) {
                var jsonData;
                try {
                    jsonData = JSON.parse(message);
                    this.updateInfo(jsonData);

                    if (jsonData.state === "started") {
                        this.endProgress();
                    }
                } catch (exception) {
                    console.log("Error parsing JSON in failure callback:" + exception);
                    console.log(message);
                    this.endProgress();
                }
            };
            blinkup.invokeBlinkUp(apiKey, planId, timeoutMs, true, success, failure);
        });
    },
    // Update DOM on a Received Event
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

function startProgress() {
    document.getElementById('progress-bar-wrapper').style.display = "inline-block";

    var progressBar = document.getElementById('progress-bar');
    progressBar.style.width = "0px";

    clearInterval(interval);
    var percentDone = 0;
    interval = setInterval(function () {
        percentDone++;
        progressBar.style.width = percentDone + "%";
        if (percentDone > 99) {
            clearInterval(interval);
        }
    }, (timeoutMs / 100));
}

function endProgress() {
    document.getElementById('progress-bar').style.width = "0px";
    document.getElementById('progress-bar-wrapper').style.display = "none";
}

function updateInfo(pluginResult) {

    // clear current info
    document.getElementById('status').innerHTML = "";
    document.getElementById('planId').innerHTML = "";
    document.getElementById('deviceId').innerHTML = "";
    document.getElementById('agentURL').innerHTML = "";
    document.getElementById('verificationDate').innerHTML = "";

    var status = "";

    if (pluginResult.state == "error") {
        if (pluginResult.error.errorType == "blinkup") {
            status = pluginResult.error.errorMsg;
        } else {
            status = errorMessageForCode(pluginResult.error.errorCode);
        }
    } else if (pluginResult.state == "completed" || pluginResult.state == "started") {
        status = statusMessageForCode(pluginResult.statusCode);
        if (pluginResult.statusCode == "0") {
            document.getElementById('planId').innerHTML = pluginResult.deviceInfo.planId;
            document.getElementById('deviceId').innerHTML = pluginResult.deviceInfo.deviceId;
            document.getElementById('agentURL').innerHTML = pluginResult.deviceInfo.agentURL;
            document.getElementById('verificationDate').innerHTML = pluginResult.deviceInfo.verificationDate;
        }
    }
    document.getElementById('status').innerHTML = status;
}

function statusMessageForCode(statusCode) {
    var integerCode = parseInt(statusCode);
    switch (integerCode) {
    case 0:
        return "Device Connected.";
    case 200:
        return "Gathering device info...";
    case 201:
        return "Wireless configuration cleared.";
    default:
        return statusCode;
    }
}

function errorMessageForCode(errorCode) {
    var integerCode = parseInt(errorCode);
    switch (integerCode) {
    case 100:
        return "Error. Invalid arguments in call to invokeBlinkUp(apiKey: String, planId: String, timeoutMs: Integer, useCachedPlanId: Bool, success: Callback, failure: Callback).";
    case 101:
        return "Error. Could not gather device info. Process timed out.";
    case 102:
        return "Process cancelled by user.";
    case 103:
        return "Error. Invalid API key. You must set your BlinkUp API key in Cordova-BlinkUpSample/www/js/index.js.";
    case 104:
        return "Error. Could not verify API key with Electric Imp servers.";
    default:
        return errorCode;
    }
}

app.initialize();