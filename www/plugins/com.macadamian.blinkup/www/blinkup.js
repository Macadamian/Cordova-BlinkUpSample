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
/*global cordova, module*/

cordova.define("com.macadamian.blinkup.blinkup", function(require, exports, module) { 
    module.exports = {
        //apiKey: string, developerPlanId: string, timeoutMs: int, useCachedPlanId: bool 
        invokeBlinkUp: function (apiKey, developerPlanId, timeoutMs, useCachedPlanId, successCallback, errorCallback) {
            cordova.exec(successCallback, errorCallback, "BlinkUpPlugin", "invokeBlinkUp", [apiKey, developerPlanId, timeoutMs, useCachedPlanId]);
        },
        abortBlinkUp: function (successCallback, errorCallback) {
            cordova.exec(successCallback, errorCallback, "BlinkUpPlugin", "abortBlinkUp", []);
        },
        clearWifiAndCache: function (successCallback, errorCallback) {
            cordova.exec(successCallback, errorCallback, "BlinkUpPlugin", "clearWifiAndCache", []);
        }
    };
});
