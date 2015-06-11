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

#import "BlinkUp.h"

@implementation BlinkUp

//------------------------------------------
// Need to hold on to callbackId to send 2nd
// message when device polling complete
//------------------------------------------
NSString *apiKey;
NSString *callbackId;
long timeoutMs;
bool useCachedPlanId = true;
BUBasicController *blinkUpController;

/*********************************************************
 * Called by Javascript in Cordova application.
 * `command.arguments` is array, first item is apiKey
 ********************************************************/
- (void)initiateBlinkUp:(CDVInvokedUrlCommand*)command {
    
    callbackId = command.callbackId;
    
    if (command.arguments.count < 3) {
        NSString *error = @"Error. Invalid argument count in call to initiateBlinkUp(apiKey: String, timeoutMs: Integer, useCachedPlanId: Bool, success: Callback, failure: Callback)";
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    apiKey = [command.arguments objectAtIndex:0];
    timeoutMs = [[command.arguments objectAtIndex:1] longValue];
    useCachedPlanId = [[command.arguments objectAtIndex:2] boolValue];
    
    [self presentBlinkUp];
}


/*********************************************************
 * shows default UI for BlinkUp process. Modify this method
 * if you wish to use a custom UI (refer to API docs)
 ********************************************************/
- (void) presentBlinkUp {
    
    // load cached planID (if not cached yet, BlinkUp automatically generates a new one)
    NSString *planId = [[NSUserDefaults standardUserDefaults] objectForKey:@"planId"];
    
    // set your developer planId here to allow the imps to show up in the Electric Imp IDE
    // see electricimp.com/docs/manufacturing/planids/ for info about planIDs
    #ifdef DEBUG
        planId = nil;
    #endif
    
    if (useCachedPlanId) {
        blinkUpController = [[BUBasicController alloc] initWithApiKey:apiKey planId:planId];
    }
    else {
        blinkUpController = [[BUBasicController alloc] initWithApiKey:apiKey];
    }
    
    [blinkUpController presentInterfaceAnimated:YES
        resignActive: ^(BOOL willRespond, BOOL userDidCancel, NSError *error) {
            [self interfaceResignedActive:willRespond userDidCancel:userDidCancel error:error];
        }
        devicePollingDidComplete: ^(BUDeviceInfo *deviceInfo, BOOL timedOut, NSError *error) {
            [self devicePollingComplete:deviceInfo timedOut:timedOut error:error];
        }
     ];
}


/*********************************************************
 * Called when BlinkUp controller is closed, by user
 * cancelling, flashing process complete, or on error.
 * Sends status back to Cordova app.
 ********************************************************/
- (void) interfaceResignedActive:(BOOL)willRespond userDidCancel:(BOOL)userDidCancel error:(NSError*)error {
    
    CDVCommandStatus status;
    NSString *messageStr = @"";
    
    if (willRespond) {
        
        // since can't set timeout manually, we just tell devicePoller to stop polling (if timeout not default)
        if (timeoutMs != 60000) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeoutMs * NSEC_PER_MSEC),
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                               [blinkUpController.devicePoller stopPolling];
                               [self devicePollingComplete:nil timedOut:true error:nil];
                           });
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"Gathering device info..." forKey:@"status"];
        [dict setValue:@"true" forKey:@"gatheringDeviceInfo"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        
        messageStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        status = CDVCommandStatus_OK;
    }
    else if (userDidCancel) {
        messageStr = @"Process cancelled by user.";
        status = CDVCommandStatus_ERROR;
    }
    else if (error != nil) {
        messageStr = [@"Error. " stringByAppendingString:error.localizedDescription];
        status = CDVCommandStatus_ERROR;
    }
    else {
        messageStr = @"Wireless configuration cleared.";
        status = CDVCommandStatus_OK;
    }
    
    // send result, and keep callback if gathering device info
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:status messageAsString:messageStr];
    if (willRespond) {
        [result setKeepCallbackAsBool:YES];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}


/*********************************************************
 * Called when device info has been loaded from Electric
 * Imp server, or when that request timed out.
 * Sends device info and status back to Cordova app.
 ********************************************************/
- (void) devicePollingComplete:(BUDeviceInfo*)deviceInfo timedOut:(BOOL)timedOut error:(NSError*)error {
    
    CDVCommandStatus status;
    NSString *messageStr = @"";
    
    if (timedOut) {
        messageStr = @"Error. Could not gather device info. Process timed out.";
        status = CDVCommandStatus_ERROR;
    }
    else if (error != nil) {
        messageStr = [@"Error. " stringByAppendingString:error.localizedDescription];
        status = CDVCommandStatus_ERROR;
    }
    else {
        // cache plan ID (see electricimp.com/docs/manufacturing/planids/)
        [[NSUserDefaults standardUserDefaults] setObject:deviceInfo.planId forKey:@"planId"];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"Device Connected"             forKey:@"status"];
        [dict setValue:deviceInfo.planId               forKey:@"planId"];
        [dict setValue:deviceInfo.deviceId             forKey:@"deviceId"];
        [dict setValue:deviceInfo.agentURL.description forKey:@"agentURL"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        
        messageStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        status = CDVCommandStatus_OK;
    }
    
    // send result, discard callback
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:status messageAsString:messageStr];
    [result setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

@end
