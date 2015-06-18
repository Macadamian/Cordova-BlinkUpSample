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

#import <Cordova/CDV.h>

@interface BlinkUpPluginResult : NSObject

- (id) initWithCallbackId:(NSString *)callbackId delegate:(id <CDVCommandDelegate>)commandDelegate;

- (void) putStatusCode:(NSString *)statusCode;
- (void) setErrorMsgFromError:(NSError *)error;
- (void) putPlanId:(NSString *)planId;
- (void) putDeviceId:(NSString *)deviceId;
- (void) putAgentURL:(NSString *)agentURL;

- (void) putGatheringDeviceInfo:(BOOL)gatheringDeviceInfo;
- (void) putStatusOK:(BOOL)statusOK;
- (void) putKeepCallbackAsBool:(BOOL)keepCallback;

- (void) sendResultsToCallback;

//=====================================
// Used to send results back to Cordova
//=====================================
@property NSString *callbackId;
@property id<CDVCommandDelegate> commandDelegate;
@property BOOL keepCallback;

//=====================================
// BlinkUp results
//=====================================
@property BOOL statusOK;
@property BOOL gatheringDeviceInfo;
@property NSString *statusCode;
@property NSString *errorMsg;
@property NSString *planId;
@property NSString *deviceId;
@property NSString *agentURL;

@end
