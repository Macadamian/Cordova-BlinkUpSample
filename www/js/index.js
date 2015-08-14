/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Created by Stuart Douglas (sdouglas@macadamian.com) on June 11, 2015.
 * Copyright (c) 2015 Macadamian. All rights reserved.
 */

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

        // Continue From Launch Page --------------------------
        var continueBtn = document.getElementById('continue-button');
        continueBtn.addEventListener('click', function () {
            document.getElementById('view-firstlaunch').style.display = "none";
            document.getElementById('view-main').style.display = "block";
        });        

        skipFirstLaunchIfDeviceInfoAvailable();
        displayDeviceInfoIfAvailable();

        // parses returned json, sets UI accordingly
        var blinkUpCallback = function (message) {
            try {
                var pluginResult = JSON.parse(message);
                updateProgress(pluginResult);
                updateFieldsWithPluginResult(pluginResult);

                if (pluginResult.state === "completed") {
                    updateLocalStorage(pluginResult)
                }
            } catch (exception) {
                endProgress();
            }
        };

        // Perform Blinkup ---------------------------------------
        var blinkupBtn = document.getElementById('blinkup-button');
        blinkupBtn.addEventListener('click', function () {
            blinkup.invokeBlinkUp(apiKey, developerPlanId, timeoutMs, false, blinkUpCallback, blinkUpCallback);
        });

        // Clear Wifi & Cached PlanId ----------------------------
        var clearBtn = document.getElementById('clear-button');
        clearBtn.addEventListener('click', function () {
            blinkup.clearBlinkUpData(blinkUpCallback, blinkUpCallback);
        });
        
        // Abort BlinkUp -----------------------------------------
        var abortBtn = document.getElementById('abort-button');
        abortBtn.addEventListener('click', function () {
            blinkup.abortBlinkUp(blinkUpCallback, blinkUpCallback);
        });
    },

    // Update DOM on a Received Event
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');
    }
};

function updateProgress(pluginResult) {
    if (pluginResult.state === "started") {
        startProgress();
    } else {
        endProgress();
    }
}

function startProgress() {
    document.getElementById('abort-button').style.display = "block";
    document.getElementById('clear-button').style.display = "none";
    document.getElementById('blinkup-button').style.display = "none";
}

function endProgress() {
    document.getElementById('abort-button').style.display = "none";
    document.getElementById('blinkup-button').style.display = "block";
    document.getElementById('clear-button').style.display = "block";
}
function updateLocalStorage(pluginResult) {
    var statusCodeAsInt = parseInt(pluginResult.statusCode);

    if (statusCodeAsInt === 0) {  // blinkup completed
        saveDeviceInfo(pluginResult);
    } else if (statusCodeAsInt == 201 || statusCodeAsInt == 202) { // blinkup config cleared
        clearDeviceInfo();
    }
}

function clearDeviceInfo() {
    window.localStorage.clear();

    document.getElementById('device-info-header').style.display = "none";
    document.getElementById('device-info').style.display = "none";
    document.getElementById('no-device-info').style.display = "block";
    
}

function isDeviceInfoAvailable() {
    return window.localStorage.getItem("deviceId") !== null;
}

function saveDeviceInfo(pluginResult) {
    if (pluginResult == null || pluginResult.deviceInfo == null) {
        return;
    }
    
    window.localStorage.setItem("deviceId", pluginResult.deviceInfo.deviceId);
    window.localStorage.setItem("planId", pluginResult.deviceInfo.planId);
    window.localStorage.setItem("agentURL", pluginResult.deviceInfo.agentURL);
    window.localStorage.setItem("verificationDate", pluginResult.deviceInfo.verificationDate);
}

function displayDeviceInfoIfAvailable() {
    if (isDeviceInfoAvailable()) {
        document.getElementById('status-success').innerHTML = "Loaded cached device information.";
        document.getElementById('status-success').style.display = "block";
        document.getElementById('deviceId').innerHTML = window.localStorage.getItem("deviceId");
        document.getElementById('planId').innerHTML = window.localStorage.getItem("planId");
        setAgentURL(window.localStorage.getItem("agentURL"));
        document.getElementById('verificationDate').innerHTML = window.localStorage.getItem("verificationDate");
    }
}

function skipFirstLaunchIfDeviceInfoAvailable() {
    if (isDeviceInfoAvailable()) {
        document.getElementById('view-firstlaunch').style.display = "none";
        document.getElementById('view-main').style.display = "block";
    }
}

function setAgentURL(agentUrlString) {
    var agentUrlDiv = document.getElementById('agentURL');
    agentUrlDiv.innerHTML = '';

    // create and add new link to div
    var agentUrlLink = document.createElement("a");
    agentUrlLink.href = agentUrlString;
    agentUrlLink.innerHTML = agentUrlString;
    agentUrlLink.target = "_blank";
    agentUrlDiv.appendChild(agentUrlLink);
}

function resetFields(pluginResult) {
    document.getElementById('status-error').innerHTML = "";
    document.getElementById('status-success').innerHTML = "";
    document.getElementById('status-error').style.display = "none";
    document.getElementById('status-success').style.display = "none";
    document.getElementById('status-gathering').style.display = "none";

    document.getElementById('planId').innerHTML = "";
    document.getElementById('deviceId').innerHTML = "";
    document.getElementById('planId').innerHTML = "";
    setAgentURL("");
    document.getElementById('verificationDate').innerHTML = "";
}

function updateFieldsWithPluginResult(pluginResult) {
    resetFields();

    var statusMsg = "";
    if (pluginResult.state == "error") {
        if (pluginResult.error.errorType == "blinkup") {
            statusMsg = pluginResult.error.errorMsg;
            document.getElementById('status-error').innerHTML = statusMsg;
            document.getElementById('status-error').style.display = "block";              
        } else if (pluginResult.error.errorCode == "102" && isDeviceInfoAvailable()) {  // user cancelled...
            displayDeviceInfoIfAvailable();
        }  else {
            statusMsg = ErrorMessages[pluginResult.error.errorCode];
            document.getElementById('status-error').innerHTML = statusMsg;
            document.getElementById('status-error').style.display = "block";
        }
    } else if (pluginResult.state == "completed" || pluginResult.state == "started") {
        statusMsg = StatusMessages[pluginResult.statusCode];

        if (pluginResult.statusCode == "200" ){
            document.getElementById('status-gathering').style.display = "block";
        } else if (pluginResult.statusCode == "0") {
            document.getElementById('planId').innerHTML = pluginResult.deviceInfo.planId;
            document.getElementById('deviceId').innerHTML = pluginResult.deviceInfo.deviceId;
            setAgentURL(pluginResult.deviceInfo.agentURL);
            document.getElementById('verificationDate').innerHTML = pluginResult.deviceInfo.verificationDate;

            document.getElementById('status-success').innerHTML = statusMsg;
            document.getElementById('status-success').style.display = "block";            
        } else {
            document.getElementById('status-success').innerHTML = statusMsg;
            document.getElementById('status-success').style.display = "block";                        
        }
    }
}

var StatusMessages = {
    0   : "Device Connected.",
    200 : "Gathering device info...",
    201 : "Wireless configuration cleared.",
    202 : "Wireless configuration and cached Plan ID cleared."
};

var ErrorMessages = {   
    100 : "Error: Invalid arguments in call to invokeBlinkUp",
    101 : "Error: Could not gather device info. Process timed out", 
    102 : "Process cancelled by user", 
    103 : "Error: Invalid API key, you must set your BlinkUp API key in Cordova-BlinkUpSample/www/js/index.js",
    
    // android only codes
    301 : "Error: Could not verify API key with Electric Imp servers",
    302 : "Error: Generating JSON string"
};

app.initialize();
