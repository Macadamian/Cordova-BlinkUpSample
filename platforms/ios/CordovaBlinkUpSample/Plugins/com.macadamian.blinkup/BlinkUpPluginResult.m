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

#import "BlinkUpPluginResult.h"

@implementation BlinkUpPluginResult


//=====================================
// JSON keys for results
//=====================================
NSString * const STATUS_KEY = @"status";
NSString * const ERROR_MSG_KEY = @"errorMsg";
NSString * const PLAN_ID_KEY = @"planId";
NSString * const DEVICE_ID_KEY = @"deviceId";
NSString * const AGENT_URL_KEY = @"agentURL";
NSString * const GATHERING_DEVICE_INFO_KEY = @"gatheringDeviceInfo";


/********************************************
 * inits with the callbackID and the
 * CDVCommandDelegate of the plugin
 ********************************************/
-(id)initWithCallbackId:(NSString *)callbackId delegate:(id <CDVCommandDelegate>)commandDelegate {
    self = [super init];
    if (self) {
        //set callbacks
        self.callbackId = callbackId;
        self.commandDelegate = commandDelegate;

        // set default values
        self.statusOK = false;
        self.gatheringDeviceInfo = false;
        self.keepCallback = false;
        self.statusCode = @"";
    }
    return self;
}

/********************************************
 * setters for our results (if we call them
 * setVariable then obj-c complains as it
 * wants a getter too, so I went with put)
 ********************************************/
- (void) putStatusCode:(NSString *)statusCode {
    self.statusCode = statusCode;
}
- (void) setErrorMsgFromError:(NSError *)error {
    NSString *errorMsg = [NSString stringWithFormat:@"BlinkUp Error #%ld: %@", (long) error.code, error.localizedDescription];
    self.errorMsg = errorMsg;
}
- (void) putPlanId:(NSString *)planId {
    self.planId = planId;
}

- (void) putDeviceId:(NSString *)deviceId {
    self.deviceId = deviceId;
}
- (void) putAgentURL:(NSString *)agentURL {
    self.agentURL = agentURL;
}

/********************************************
 * setters for boolean values
 ********************************************/
- (void) putGatheringDeviceInfo:(BOOL)gatheringDeviceInfo {
    self.gatheringDeviceInfo = gatheringDeviceInfo;
}
- (void) putStatusOK:(BOOL)statusOK {
    self.statusOK = statusOK;
}
- (void) putKeepCallbackAsBool:(BOOL)keepCallback {
    keepCallback = keepCallback;
}

/********************************************
 * Sends a JSON string of the results back
 * to the callback, or if we only have a
 * status string, sends that (not in JSON)
 ********************************************/
- (void) sendResultsToCallback {

    NSString *resultString = @"";
    CDVCommandStatus status = (self.statusOK) ? CDVCommandStatus_OK : CDVCommandStatus_ERROR;
    
    // only have status, so no need to send json
    if ((self.deviceId == nil && self.planId == nil && self.agentURL == nil) && !self.gatheringDeviceInfo && self.errorMsg == nil) {
        resultString = self.statusCode;
    }

    else {
        NSString *gatheringDeviceInfoStr = self.gatheringDeviceInfo ? @"true" : @"false";
        
        // put results in dictionary (status and gatheringDeviceInfo can't be null)
        NSMutableDictionary *resultsDict = [[NSMutableDictionary alloc] init];
        [resultsDict setObject:self.statusCode forKey:STATUS_KEY];
        [resultsDict setObject:gatheringDeviceInfoStr forKey:GATHERING_DEVICE_INFO_KEY];
        
        if (self.planId != nil) {
            [resultsDict setObject:self.planId forKey:PLAN_ID_KEY];
        }
        if (self.deviceId != nil) {
            [resultsDict setObject:self.deviceId forKey:DEVICE_ID_KEY];
        }
        if (self.agentURL != nil) {
            [resultsDict setObject:self.agentURL forKey:AGENT_URL_KEY];
        }
        if (self.errorMsg != nil) {
            [resultsDict setObject:self.errorMsg forKey:ERROR_MSG_KEY];
        }
        
        resultString = [self toJsonString:resultsDict];
    }
    
    //send results
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:status messageAsString:resultString];
    [result setKeepCallbackAsBool: self.keepCallback];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

/********************************************
 * Takes dictionary and outputs a JSON string
 ********************************************/
- (NSString *) toJsonString:(NSMutableDictionary *)resultsDict {
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultsDict options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (jsonError != nil) {
        NSLog(@"Error converting to JSON. %@", jsonError.localizedDescription);
        return @"";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
