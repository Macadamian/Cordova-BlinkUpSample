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

/* ========== JSON Format Reference ================
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
 ===================================================*/

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
- (NSString *)getResults;
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
