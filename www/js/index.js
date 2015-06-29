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

/*global blinkup*/

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

        loadDeviceInfoIfAvailable();

        // parses returned json, sets UI accordingly
        var blinkUpCallback = function (message) {
            var jsonData;
            try {
                jsonData = JSON.parse(message);
                this.updateInfo(jsonData);
                if (jsonData.state === "started") {
                    this.startProgress();
                } else {
                    this.endProgress();
                    if (jsonData.state === "completed") {
                        this.saveDeviceInfo(jsonData);
                    }
                }
            } catch (exception) {
                console.log("Error parsing JSON in blinkUpCallback:" + exception);
                this.endProgress();
            }
        };

        // Perform Blinkup ---------------------------------------
        var blinkupBtn = document.getElementById('blinkup-button');
        blinkupBtn.addEventListener('click', function () {
            blinkup.invokeBlinkUp(apiKey, planId, timeoutMs, false, blinkUpCallback, blinkUpCallback);
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

        console.log('Received Event: ' + id);
    }
};

/******************************************
 * shows abort button, hides others
 *****************************************/
function startProgress() {
    document.getElementById('abort-button').style.display = "block";
    document.getElementById('clear-button').style.display = "none";
    document.getElementById('blinkup-button').style.display = "none";
}

/******************************************
 * shows blinkup & clear btns, hides abort
 *****************************************/
function endProgress() {
    document.getElementById('abort-button').style.display = "none";
    document.getElementById('blinkup-button').style.display = "block";
    document.getElementById('clear-button').style.display = "block";
}

/********************************************
 * Saves device info persistently 
 * @param JSON object of BlinkUpPlugin results
 ********************************************/
function saveDeviceInfo(pluginResult) {
    var statusCodeAsInt = parseInt(pluginResult.statusCode);
    
    // clear cache when wifi cleared
    if (statusCodeAsInt === 201 || statusCodeAsInt === 202) {
        window.localStorage.clear();
    }
    
    // save device info to persistent storage
    else if (statusCodeAsInt === 0) {
        window.localStorage.setItem("deviceId", pluginResult.deviceInfo.deviceId);
        window.localStorage.setItem("planId", pluginResult.deviceInfo.planId);
        window.localStorage.setItem("agentURL", pluginResult.deviceInfo.agentURL);
        window.localStorage.setItem("verificationDate", pluginResult.deviceInfo.verificationDate);
    }
}

/********************************************
 * loads cached deviceInfo and updates UI
 ********************************************/
function loadDeviceInfoIfAvailable() {
    // if one item not null, all not null (they are all set at same time)
    if (window.localStorage.getItem("deviceId") !== null) {
        document.getElementById('status-success').innerHTML = "Loaded cached device information.";
        document.getElementById('status-success').style.display = "block";
        document.getElementById('deviceId').innerHTML = window.localStorage.getItem("deviceId");
        document.getElementById('planId').innerHTML = window.localStorage.getItem("planId");
        document.getElementById('agentURL').innerHTML = window.localStorage.getItem("agentURL");
        document.getElementById('verificationDate').innerHTML = window.localStorage.getItem("verificationDate");
    }
}

/********************************************
 * updates UI according to result of BlinkUp
 * @param JSON object of BlinkUpPlugin result
 ********************************************/
function updateInfo(pluginResult) {
    // clear current info
    document.getElementById('status-error').innerHTML = "";
    document.getElementById('status-success').innerHTML = "";
    document.getElementById('status-error').style.display = "none";
    document.getElementById('status-success').style.display = "none";
    document.getElementById('status-gathering').style.display = "none";

    document.getElementById('planId').innerHTML = "";
    document.getElementById('deviceId').innerHTML = "";
    document.getElementById('planId').innerHTML = "";
    document.getElementById('agentURL').innerHTML = "";
    document.getElementById('verificationDate').innerHTML = "";

    var statusMsg = "";

    if (pluginResult.state == "error") {
        if (pluginResult.error.errorType == "blinkup") {
            statusMsg = pluginResult.error.errorMsg;
            document.getElementById('status-error').innerHTML = statusMsg;
            document.getElementById('status-error').style.display = "block";              
        } else {
            statusMsg = ErrorMessages[pluginResult.error.errorCode];
            document.getElementById('status-error').innerHTML = statusMsg;
            document.getElementById('status-error').style.display = "block";
        }

    } else if (pluginResult.state == "completed" || pluginResult.state == "started") {
        statusMsg = StatusMessages[pluginResult.statusCode];

        if(pluginResult.statusCode === "200" ){
            document.getElementById('status-gathering').style.display = "block";
        } else if (pluginResult.statusCode == "0") {
            document.getElementById('planId').innerHTML = pluginResult.deviceInfo.planId;
            document.getElementById('deviceId').innerHTML = pluginResult.deviceInfo.deviceId;
            document.getElementById('agentURL').innerHTML = pluginResult.deviceInfo.agentURL;
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
    300 : "Error: Invalid API key, you must set your BlinkUp API key in Cordova-BlinkUpSample/www/js/index.js",
    301 : "Error: Could not verify API key with Electric Imp servers",
    302 : "Error: Generating JSON string"
};

app.initialize();
