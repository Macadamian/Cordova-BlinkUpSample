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

/* ========== JSON Format Reference =============================
{
   "state": "started" | "completed" | "error", [1]
   "statusCode": "",                           [2]
   "error": {                                  [3]
       "errorType": "plugin" | "blinkup",      [4]
       "errorCode": "",                        [5]
       "errorMsg": ""                          [6]
   },
   "deviceInfo": {                             [7]
       "deviceId": "",
       "planId": "",
       "agentURL": "",
       "verificationDate": ""
   }
}
[1] - started: flashing process has finished, waiting for device
               info from Electric Imp servers
    completed: Plugin done executing. This could be a clear-wifi
               completed or device info from servers has arrived
[2] - Status of plugin. See Readme.md for status codes.
      Null if state is "error".
[3] - Stores error information if state is "error".
      Null if state is "started" or "completed".
[4] - If error sent from SDK, "blinkup".
      If error handled within native code of plugin, "plugin".
[5] - BlinkUp SDK error code if errorType is "blinkup".
      Custom error code if "plugin". See Readme.md for codes.
[6] - If errorType is "blinkup", error message from BlinkUp SDK.
      Null if errorType "plugin"
[7] - Stores the deviceInfo from the Electric Imp servers.
      Null if state = "started" or "error"
===============================================================*/

#import <Cordova/CDV.h>

@class BUDeviceInfo;

@interface BlinkUpPluginResult : NSObject

typedef NS_ENUM(NSInteger, BlinkUpPluginState) {
    Started,
    Completed,
    Error
};
typedef NS_ENUM(NSInteger, BlinkUpErrorType) {
    BlinkUpSDKError,
    PluginError
};

//*************************************
// Public methods
//*************************************
- (void) setBlinkUpError:(NSError *)error;
- (void) setPluginError:(NSInteger)errorCode;
- (NSString *)getResultsAsJsonString;
- (CDVCommandStatus) getCordovaStatus;
- (BOOL) getKeepCallback;

//=====================================
// BlinkUp result
//=====================================
@property BlinkUpPluginState state;
@property NSInteger statusCode;
@property BlinkUpErrorType errorType;
@property NSInteger errorCode;
@property NSString *errorMsg;
@property BUDeviceInfo *deviceInfo;

@end
