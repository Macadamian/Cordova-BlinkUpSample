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

//--JSLint---------------------
/*global blinkup*/
/*global statusMessageForCode*/
//-----------------------------

var apiKey = "YOUR_API_KEY_HERE";
var developerPlanId = "DEVELOPER_PLAN_ID_HERE"; //if blank or left as DEVELOPER_PLAN_ID_HERE, SDK will auto-generate a planId
var timeoutMs = 60000;
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
                    this.updateInfo(jsonData, true);
                    if (jsonData.gatheringDeviceInfo === "true") {
                        this.startProgress();
                    } else {
                        this.endProgress();
                    }
                } catch (exception) {
                    this.updateInfo(message, false);
                    this.endProgress();
                }
            };

            var failure = function (message) {
                var jsonData;
                try {
                    jsonData = JSON.parse(message);
                    this.updateInfo(jsonData, true);

                    if (jsonData.gatheringDeviceInfo === "false") {
                        this.endProgress();
                    }
                } catch (exception) {
                    this.updateInfo(message, false);
                    this.endProgress();
                }
            };

            if (developerPlanId == "DEVELOPER_PLAN_ID_HERE") {
                developerPlanId = ""; // SDK will generate planId if left blank
            }
            blinkup.invokeBlinkUp(apiKey, developerPlanId, timeoutMs, true, success, failure);
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

function updateInfo(deviceInfo, isJSON) {

    // set status
    var status = "";
    if (isJSON && deviceInfo.status == "1") {
        status = deviceInfo.errorMsg;
    } else if (isJSON && deviceInfo.status != null) {
        status = statusMessageForCode(deviceInfo.status);
    } else {
        status = statusMessageForCode(deviceInfo);
    }
    document.getElementById('status').innerHTML = status;

    // set other values if non-nil
    document.getElementById('planId').innerHTML = (isJSON && deviceInfo.planId != null) ? deviceInfo.planId : "";
    document.getElementById('deviceId').innerHTML = (isJSON && deviceInfo.deviceId != null) ? deviceInfo.deviceId : "";
    document.getElementById('agentURL').innerHTML = (isJSON && deviceInfo.agentURL != null) ? deviceInfo.agentURL : "";
}

function statusMessageForCode(statusCode) {
    var integerCode = parseInt(statusCode);
    switch (integerCode) {
    case 0:
        return "Device Connected.";
    case 1:
        return ""; // error string part of BlinkUp SDK
    case 100:
        return "Error. Invalid arguments in call to invokeBlinkUp(apiKey: String, developerPlanId: String, timeoutMs: Integer, useCachedPlanId: Bool, success: Callback, failure: Callback).";
    case 101:
        return "Error. Could not gather device info. Process timed out.";
    case 102:
        return "Process cancelled by user.";
    case 103:
        return "Error. Invalid API key. You must set your BlinkUp API key using the SetApiKey.sh script. See README.md for more details.";
    case 104:
        return "Error. Could not verify API key with Electric Imp servers.";
    case 200:
        return "Gathering device info…";
    case 201:
        return "Wireless configuration cleared.";
    default:
        return statusCode;
    }
}

app.initialize();