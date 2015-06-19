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
 * Created by Stuart Douglas (sdouglas@macadamian.com) on June 18, 2015.
 * Copyright (c) 2015 Macadamian. All rights reserved.
 */

package com.macadamian.blinkup;

import android.util.Log;

import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

public class BlinkUpPluginResult {

    /******** JSON Format ******************************
    {
        "state": "started" | "completed" | "error",
        "statusCode": "",                           [1]
        "error": {                                  [2]
            "errorType": "plugin" | "blinkup",      [3]
            "errorCode": "",                        [4]
            "errorMsg": ""                          [5]
        },
        "deviceInfo": {                             [6]
            "deviceId": "",
            "planId": "",
            "agentURL": "",
            "verificationDate": ""
        }
    }
    // [1] - null if error, see readme for status codes
    // [2] - null if "started" or "completed"
    // [3] - if error from BUErrors.h, "blinkup",
             otherwise "plugin"
    // [4] - NSError code if "blinkup", custom error code
             if "plugin". See readme for custom errors.
    // [5] - null if errorType "plugin"
    // [6] - null if "started" or "error"
    ****************************************************/

    // possible states
    public enum BlinkUpPluginState {
        Started,
        Completed,
        Error
    }

    // error types
    private enum BlinkUpErrorType {
        BlinkUpSDKError,
        PluginError
    }

    //=====================================
    // JSON keys for results
    //=====================================
    // keys for JSON sent back to javascript
    private static final String STATE_KEY = "state";
    private static final String STATUS_CODE_KEY = "statusCode";

    private static final String ERROR_KEY = "error";
    private static final String ERROR_TYPE_KEY = "errorType";
    private static final String ERROR_CODE_KEY = "errorCode";
    private static final String ERROR_MSG_KEY = "errorMsg";

    private static final String DEVICE_INFO_KEY = "deviceInfo";
    private static final String DEVICE_ID_KEY = "deviceId";
    private static final String PLAN_ID_KEY = "planId";
    private static final String AGENT_URL_KEY = "agentURL";
    private static final String VERIFICATION_DATE_KEY = "verificationDate";

    //====================================
    // BlinkUp Results
    //====================================
    private BlinkUpPluginState state;
    private int statusCode;
    private BlinkUpErrorType errorType;
    private int errorCode;
    private String errorMsg;

    private String deviceId;
    private String planId;
    private String agentURL;
    private String verificationDate;

    //====================================
    // Setters for our Results
    //====================================
    public void setState(BlinkUpPluginState state) {
        this.state = state;
    }
    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }
    public void setPluginError(int errorCode) {
        this.errorType = BlinkUpErrorType.PluginError;
        this.errorCode = errorCode;
    }
    public void setBlinkUpError(String errorMsg) {
        this.errorType = BlinkUpErrorType.BlinkUpSDKError;
        this.errorCode = 1;
        this.errorMsg = errorMsg;
    }
    public void setDeviceInfoAsJson(JSONObject deviceInfo) {
        try {
            this.deviceId = (deviceInfo.getString("impee_id") != null) ? deviceInfo.getString("impee_id").trim() : null;
            this.planId = deviceInfo.getString("plan_id");
            this.agentURL = deviceInfo.getString("agent_url");
            this.verificationDate = deviceInfo.getString("claimed_at");
        } catch (JSONException e) {
            Log.e("BlinkUpPlugin", "Error parsing device info JSON.");
            e.printStackTrace();
        }
    }

    public void sendResultsToCallback() {
        JSONObject resultJSON = new JSONObject();

        // set result status
        PluginResult.Status resultStatus;
        if (this.state == BlinkUpPluginState.Error) {
            resultStatus = PluginResult.Status.ERROR;
        }
        else {
            resultStatus = PluginResult.Status.OK;
        }

        try {
            // set our state (never null)
            if (this.state == BlinkUpPluginState.Started) {
                resultJSON.put(this.STATE_KEY, "started");
            } else if (this.state == BlinkUpPluginState.Completed) {
                resultJSON.put(this.STATE_KEY, "completed");
            } else {
                resultJSON.put(this.STATE_KEY, "error");
            }

            // error
            if (this.state == BlinkUpPluginState.Error) {
                JSONObject errorJson = new JSONObject();
                if (this.errorType == BlinkUpErrorType.BlinkUpSDKError) {
                    errorJson.put(this.ERROR_TYPE_KEY, "blinkup");
                    errorJson.put(this.ERROR_MSG_KEY, this.errorMsg);
                }
                else {
                    errorJson.put(this.ERROR_TYPE_KEY, "plugin");
                }
                errorJson.put(this.ERROR_CODE_KEY, String.valueOf(this.errorCode));
                resultJSON.put(this.ERROR_KEY, errorJson);
            }

            // success
            else {
                resultJSON.put(this.STATUS_CODE_KEY, String.valueOf(statusCode));

                if (this.deviceId != null && this.planId != null
                 && this.agentURL != null && this.verificationDate != null) {
                    JSONObject deviceInfoJson = new JSONObject();
                    deviceInfoJson.put(this.DEVICE_ID_KEY, this.deviceId);
                    deviceInfoJson.put(this.PLAN_ID_KEY, this.planId);
                    deviceInfoJson.put(this.AGENT_URL_KEY, this.agentURL);
                    deviceInfoJson.put(this.VERIFICATION_DATE_KEY, this.verificationDate);
                    resultJSON.put(this.DEVICE_INFO_KEY, deviceInfoJson);
                }
            }
        } catch (JSONException e) {
            Log.e("BlinkUpPlugin", "Error creating result JSOn.");
            e.printStackTrace();
        }

        PluginResult pluginResult = new PluginResult(resultStatus, resultJSON.toString());
        pluginResult.setKeepCallback(this.state == BlinkUpPluginState.Started);
        BlinkUpPlugin.callbackContext.sendPluginResult(pluginResult);
    }
}
