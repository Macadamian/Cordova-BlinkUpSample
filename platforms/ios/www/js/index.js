/*
<<<<<<< HEAD
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
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
 * Modified by Stuart Douglas (sdouglas@macadamian.com) on June 11, 2015.
 */

//-JSLint---------
/*global blinkup*/
//----------------

var apiKey = "YOUR_API_KEY_HERE";
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

            blinkup.initiateBlinkUp(apiKey, timeoutMs, true, success, failure);
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
    document.getElementById('status').innerHTML   = (isJSON && deviceInfo.status   != null) ? deviceInfo.status   : deviceInfo;
    document.getElementById('planId').innerHTML   = (isJSON && deviceInfo.planId   != null) ? deviceInfo.planId   : "";
    document.getElementById('deviceId').innerHTML = (isJSON && deviceInfo.deviceId != null) ? deviceInfo.deviceId : "";
    document.getElementById('agentURL').innerHTML = (isJSON && deviceInfo.agentURL != null) ? deviceInfo.agentURL : "";
}

app.initialize();