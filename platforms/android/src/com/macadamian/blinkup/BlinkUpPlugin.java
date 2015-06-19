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

package com.macadamian.blinkup;

import android.content.Intent;
import android.content.SharedPreferences;
import android.widget.Toast;
import org.json.JSONArray;
import org.json.JSONException;

import com.electricimp.blinkup.BlinkupController;

import org.apache.cordova.*;

/*********************************************
 * execute() called from Javascript interface,
 * which saves the arguments and presents the
 * BlinkUpPlugin interface from the SDK
 ********************************************/
public class BlinkUpPlugin extends CordovaPlugin {

    // only needed in this class
    private String apiKey;
    private String developerPlanId;
    private Boolean useCachedPlanId = false;

    // accessed from BlinkUpCompleteActivity and ClearCompleteActivity
    public static int timeoutMs = 60000;
    public static CallbackContext callbackContext;

    final int BlinkUpArgumentApiKey = 0;
    final int BlinkUpArgumentDeveloperPlanId = 1;
    final int BlinkUpArgumentTimeOut = 2;
    final int BlinkUpUsedCachedPlanId = 3;

    public static final int DEVICE_CONNECTED = 0;
    public static final int GATHERING_INFO = 200;
    public static final int CLEAR_COMPLETE = 201;

    public static final int INVALID_ARGUMENTS = 100;
    public static final int PROCESS_TIMED_OUT = 101;
    public static final int CANCELLED_BY_USER = 102;
    public static final int INVALID_API_KEY = 103;
    public static final int VERIFY_API_KEY_FAIL = 104;

    /**********************************************************
     * method called by Cordova javascript
     *********************************************************/
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {

        this.callbackContext = callbackContext;

        if (action.equalsIgnoreCase("invokeBlinkUp")) {
            try {
                this.apiKey = data.getString(BlinkUpArgumentApiKey);
                this.developerPlanId = data.getString(BlinkUpArgumentDeveloperPlanId);
                this.timeoutMs = data.getInt(BlinkUpArgumentTimeOut);
                this.useCachedPlanId = data.getBoolean(BlinkUpUsedCachedPlanId);
            } catch (JSONException exc) {
                BlinkUpPluginResult pluginResult = new BlinkUpPluginResult();
                pluginResult.setState(BlinkUpPluginResult.BlinkUpPluginState.Error);
                pluginResult.setPluginError(this.INVALID_ARGUMENTS);
                pluginResult.sendResultsToCallback();
                return false;
            }

            // default is to run on WebCore thread, we have UI so need UI thread
            this.cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    presentBlinkUp();
                }
            });
        }

        else if (action.equalsIgnoreCase("abortBlinkUp")) {
            BlinkupController.getInstance().cancelTokenStatusPolling();

            BlinkUpPluginResult pluginResult = new BlinkUpPluginResult();
            pluginResult.setState(BlinkUpPluginResult.BlinkUpPluginState.Error);
            pluginResult.setPluginError(this.CANCELLED_BY_USER);
            pluginResult.sendResultsToCallback();
        }
        return true;
    }

    /**********************************************************
     * shows BlinkUpPlugin activity and handles appropriate callbacks
     *********************************************************/
    private void presentBlinkUp() {

        // show toast if can't acquire token
        final BlinkupController.TokenAcquireCallback tokenAcquireCallback = new BlinkupController.TokenAcquireCallback() {
            @Override
            public void onSuccess(String planId, String id) { }

            @Override
            public void onError(String s) {
                // show more descriptive message if api key not valid, i.e. 401 authentication failure
                if (s.contains("401")) {
                    Toast.makeText(cordova.getActivity(), "Error. Invalid BlinkUp API key.", Toast.LENGTH_LONG).show();
                    BlinkUpPluginResult pluginResult = new BlinkUpPluginResult();
                    pluginResult.setState(BlinkUpPluginResult.BlinkUpPluginState.Error);
                    pluginResult.setPluginError(INVALID_API_KEY);
                    pluginResult.sendResultsToCallback();
                }
                else {
                    Toast.makeText(cordova.getActivity(), ("Error. " + s), Toast.LENGTH_SHORT).show();
                }
            }
        };

        // send back error if connectivity issue
        BlinkupController.ServerErrorHandler serverErrorHandler= new BlinkupController.ServerErrorHandler() {
            @Override
            public void onError(String s) {
                BlinkUpPluginResult pluginResult = new BlinkUpPluginResult();
                pluginResult.setState(BlinkUpPluginResult.BlinkUpPluginState.Error);
                pluginResult.setStatusCode(VERIFY_API_KEY_FAIL);
                pluginResult.sendResultsToCallback();
            }
        };

        // load cached planId if available. Otherwise, SDK generates new one automatically
        if (this.useCachedPlanId) {
            SharedPreferences preferences = this.cordova.getActivity().getSharedPreferences("DefaultPreferences", this.cordova.getActivity().MODE_PRIVATE);
            String planId = preferences.getString("planId", null);
            BlinkupController.getInstance().setPlanID(planId);
        }

        // see electricimp.com/docs/manufacturing/planids/ for info about planIDs
        if (org.apache.cordova.BuildConfig.DEBUG) {
            BlinkupController.getInstance().setPlanID(this.developerPlanId);
        }

        BlinkupController.getInstance().acquireSetupToken(this.cordova.getActivity(), this.apiKey, tokenAcquireCallback);

        // onActivityResult called on MainActivity (i.e. cordova.getActivity()) when blinkup or clear
        // complete. It calls handleActivityResult on blinkupController, which initiates the following intents
        BlinkupController.getInstance().intentBlinkupComplete = new Intent(this.cordova.getActivity(), BlinkUpCompleteActivity.class);
        BlinkupController.getInstance().intentClearComplete = new Intent(this.cordova.getActivity(), ClearCompleteActivity.class);

        BlinkupController.getInstance().selectWifiAndSetupDevice(this.cordova.getActivity(), this.apiKey, serverErrorHandler);
    }
}