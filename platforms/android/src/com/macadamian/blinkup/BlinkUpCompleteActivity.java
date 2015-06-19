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

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;

import com.electricimp.blinkup.BlinkupController;

import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

/*****************************************************
 * When the BlinkUpPlugin process completes, it executes the
 * BlinkUpCompleteIntent set in BlinkUpPlugin.java, starting
 * this activity, which requests the setup info from
 * the Electric Imp server, dismisses itself, and
 * sends the info back to the callback when received.
 *****************************************************/
public class BlinkUpCompleteActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getDeviceInfo();

        // send callback that we're waiting on server
        JSONObject resultJSON = new JSONObject();
        try {
            resultJSON.put(BlinkUpPlugin.STATUS_KEY, "Gathering device info...");
            resultJSON.put(BlinkUpPlugin.GATHERING_DEVICE_INFO_KEY, "true");

            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultJSON.toString());
            pluginResult.setKeepCallback(true);
            BlinkUpPlugin.callbackContext.sendPluginResult(pluginResult);
        } catch (JSONException e) {
            Log.e("BlinkUpPlugin","JSON Exception: " + e.toString());
        }

        this.finish();
    }

    private void getDeviceInfo() {
        final BlinkupController.TokenStatusCallback tokenStatusCallback= new BlinkupController.TokenStatusCallback() {

            //---------------------------------
            // give connection info to Cordova
            //---------------------------------
            @Override public void onSuccess(JSONObject json) {
                try {
                    String deviceId = (json.getString("impee_id") != null) ? json.getString("impee_id").trim() : null;
                    String agentURL = json.getString("agent_url");

                    JSONObject resultJSON = new JSONObject();
                    resultJSON.put(BlinkUpPlugin.STATUS_KEY, "Device Connected");
                    resultJSON.put(BlinkUpPlugin.GATHERING_DEVICE_INFO_KEY, "false");
                    resultJSON.put(BlinkUpPlugin.PLAN_ID_KEY, json.getString("plan_id"));
                    resultJSON.put(BlinkUpPlugin.DEVICE_ID_KEY, deviceId);
                    resultJSON.put(BlinkUpPlugin.AGENT_URL_KEY, agentURL);

                    // cache planID (see electricimp.com/docs/manufacturing/planids/)
                    SharedPreferences preferences = getSharedPreferences("DefaultPreferences", MODE_PRIVATE);
                    SharedPreferences.Editor editor = preferences.edit();
                    editor.putString(BlinkUpPlugin.PLAN_ID_KEY, json.getString("plan_id"));
                    editor.apply();

                    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultJSON.toString());
                    pluginResult.setKeepCallback(true);
                    BlinkUpPlugin.callbackContext.sendPluginResult(pluginResult);
                }
                catch (JSONException e) {
                    Log.e("BlinkUpPlugin", e.getMessage());
                }
            }

            //---------------------------------
            // give error msg to Cordova
            //---------------------------------
            @Override public void onError(String errorMsg) {
                JSONObject resultJSON = new JSONObject();
                try {
                    resultJSON.put(BlinkUpPlugin.STATUS_KEY, BlinkUpPlugin.ERROR);
                    resultJSON.put(BlinkUpPlugin.ERROR_MSG_KEY, errorMsg);
                } catch (JSONException e) {
                    Log.e("BlinkUpPlugin", e.getMessage());
                }

                PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, resultJSON.toString());;
                pluginResult.setKeepCallback(true);
                BlinkUpPlugin.callbackContext.sendPluginResult(pluginResult);
            }

            //---------------------------------
            // give timeout message to Cordova
            //---------------------------------
            @Override public void onTimeout() {
                PluginResult pluginResult = new PluginResult(PluginResult.Status.ERROR, "Error. Could not gather device information. Process timed out."");
                BlinkUpPlugin.callbackContext.sendPluginResult(pluginResult);
            }
        };

        // request the device info from the server
        BlinkupController.getInstance().getTokenStatus(tokenStatusCallback, BlinkUpPlugin.timeoutMs);
    }
}