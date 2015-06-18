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

import org.apache.cordova.CallbackContext;
import com.electricimp.blinkup.BlinkupController;

/**************************************
 * stores several objects required
 * by multiple classes in application
 *************************************/
public class Globals {
    public static CallbackContext callbackContext;
    public static BlinkupController blinkUpController;
    public static int timeoutMs = 60000; // default is 1 minute

    // keys for JSON sent back to javascript
    public static final String STATUS_KEY = "status";
    public static final String GATHERING_DEVICE_INFO_KEY = "gatheringDeviceInfo";
    public static final String PLAN_ID_KEY = "planId";
    public static final String DEVICE_ID_KEY = "deviceId";
    public static final String AGENT_URL_KEY = "agentURL";

    // == Status codes ====================================
    public static final String DEVICE_CONNECTED    = "0";
    public static final String ERROR               = "1";

    public static final String INVALID_ARGUMENTS   = "100";
    public static final String PROCESS_TIMED_OUT   = "101";
    public static final String CANCELLED_BY_USER   = "102"; //iOS only
    public static final String INVALID_API_KEY     = "103";
    public static final String VERIFY_API_KEY_FAIL = "104";

    public static final String GATHERING_INFO      = "200";
    public static final String CLEAR_COMPLETE      = "201";
    // ====================================================
}
