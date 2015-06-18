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

    // Only needed in this class, so not in Globals.getInstance()
    private String apiKey;
    private Boolean useCachedPlanId = false;

    /**********************************************************
     * method called by Cordova javascript
     *********************************************************/
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if (action.equalsIgnoreCase("invokeBlinkUp")) {

            Globals.getInstance().callbackContext = callbackContext;
            try {
                this.apiKey = data.getString(0);
                Globals.getInstance().timeoutMs = data.getInt(1);
                this.useCachedPlanId = data.getBoolean(2);
            } catch (JSONException exc) {
                String error = "Error. Invalid argument count in call to invoke blink up (apiKey: String, timeoutMs: Integer, useCachedPlanId: Bool, success: Callback, failure: Callback)";
                callbackContext.error(error);
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
                    String errorMsg = "Error. Invalid API key. You must set your BlinkUp API key using the SetApiKey.sh script. See README.md for more details.";
                    Toast.makeText(cordova.getActivity(), errorMsg, Toast.LENGTH_LONG).show();
                    Globals.getInstance().callbackContext.error(errorMsg);
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
                Globals.getInstance().callbackContext.error("Error. Could not verify API key with Electric Imp servers.");
            }
        };

        // initialize controller
        Globals.getInstance().blinkUpController = BlinkupController.getInstance();

        // load cached planId if available. Otherwise, SDK generates new one automatically
        if (this.useCachedPlanId) {
            SharedPreferences preferences = this.cordova.getActivity().getSharedPreferences("DefaultPreferences", this.cordova.getActivity().MODE_PRIVATE);
            String planId = preferences.getString(Globals.getInstance().PLAN_ID_KEY, null);
            Globals.getInstance().blinkUpController.setPlanID(planId);
        }

        // set developerPlanId here to see device in Electric Imp IDE if in Debug Mode
        // see electricimp.com/docs/manufacturing/planids/ for info about planIDs
        if (org.apache.cordova.BuildConfig.DEBUG) {
            String developerPlanId = null;
            Globals.getInstance().blinkUpController.setPlanID(developerPlanId);
        }

        Globals.getInstance().blinkUpController.acquireSetupToken(this.cordova.getActivity(), this.apiKey, tokenAcquireCallback);

        // onActivityResult called on MainActivity (i.e. cordova.getActivity()) when blinkup or clear
        // complete. It calls handleActivityResult on blinkupController, which initiates the following intents
        Globals.getInstance().blinkUpController.intentBlinkupComplete = new Intent(this.cordova.getActivity(), BlinkUpCompleteActivity.class);
        Globals.getInstance().blinkUpController.intentClearComplete = new Intent(this.cordova.getActivity(), ClearCompleteActivity.class);

        Globals.getInstance().blinkUpController.selectWifiAndSetupDevice(this.cordova.getActivity(), this.apiKey, serverErrorHandler);
    }
}