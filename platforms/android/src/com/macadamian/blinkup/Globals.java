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

import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import com.electricimp.blinkup.BlinkupController;

/**************************************
 * stores several objects required
 * by multiple classes in application
 *************************************/
public class Globals {
    public static Context currentContext;
    public static CallbackContext callbackContext;
    public static BlinkupController blinkUpController;
    public static int timeoutMs = 60000; // default is 1 minute

    // keys for JSON sent back to javascript
    public static final String STATUS_KEY = "status";
    public static final String GATHERING_DEVICE_INFO_KEY = "gatheringDeviceInfo";
    public static final String PLAN_ID_KEY = "planId";
    public static final String DEVICE_ID_KEY = "deviceId";
    public static final String AGENT_URL_KEY = "agentURL";

    /**********************************************************
     * Returns string from res/values/strings.xml with passed
     * identifier. Returns "" on error.
     *********************************************************/
    public static String getStringRes(String identifier) {

        // package name different for each app so need to do this dynamically
        PackageManager packageManager = currentContext.getPackageManager();

        try {
            Resources resources = packageManager.getResourcesForApplication(currentContext.getPackageName());
            try {
                // return string associated with id
                int resId = resources.getIdentifier(identifier, "string", currentContext.getPackageName());
                return resources.getString(resId);
            }
            catch (Resources.NotFoundException e) {
                Log.e("BlinkUpPlugin", "Resource not found. " + e.getLocalizedMessage());
            }
        } catch (PackageManager.NameNotFoundException e) {
            Log.e("BlinkUpPlugin", "Could not load package manager, name not found. " + e.getLocalizedMessage());
        }

        // return empty string on error
        return "";
    }
}
