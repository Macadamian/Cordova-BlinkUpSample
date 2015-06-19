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

#import "BlinkUpPlugin.h"
#import "BlinkUpPluginResult.h"
#import <BlinkUp/BlinkUp.h>

typedef NS_ENUM(NSInteger, BlinkupArguments) {
    BlinkUpArgumentApiKey = 0,
    BlinkUpArgumentDeveloperPlanId,
    BlinkUpArgumentTimeOut,
    BlinkUpUsedCachedPlanId
};

// status codes
typedef NS_ENUM(NSInteger, BlinkUpStatusCodes) {
    DEVICE_CONNECTED    = 0,
    GATHERING_INFO      = 200,
    CLEAR_COMPLETE      = 201
};

// error codes
typedef NS_ENUM(NSInteger, BlinkUpErrorCodes) {
    INVALID_ARGUMENTS   = 100,
    PROCESS_TIMED_OUT   = 101,
    CANCELLED_BY_USER   = 102,
    INVALID_API_KEY     = 103, // android only
    VERIFY_API_KEY_FAIL = 104, // android only
};

@implementation BlinkUpPlugin

/*********************************************************
 * Called by Javascript in Cordova application.
 * `command.arguments` is array, first item is apiKey
 ********************************************************/
- (void)invokeBlinkUp:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    if (command.arguments.count <= BlinkUpUsedCachedPlanId) {
        BlinkUpPluginResult *pluginResult = [[BlinkUpPluginResult alloc] init];
        pluginResult.state = Error;
        [pluginResult setPluginError:INVALID_ARGUMENTS];

        CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:[pluginResult getCordovaStatus] messageAsString: [pluginResult getResults]];
        [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];
        return;
    }

    self.apiKey = [command.arguments objectAtIndex:BlinkUpArgumentApiKey];
    self.developerPlanId = [command.arguments objectAtIndex:BlinkUpArgumentDeveloperPlanId];
    self.timeoutInMs = [command.arguments objectAtIndex:BlinkUpArgumentTimeOut];
    self.useCachedPlanId = [command.arguments objectAtIndex:BlinkUpUsedCachedPlanId];

    [self navigateToBlinkUpView];
}

/*********************************************************
 * nulls controller, cancelling device polling
 ********************************************************/
- (void)abortBlinkUp:(CDVInvokedUrlCommand *)command {
    self.blinkUpController = nil;

    BlinkUpPluginResult *abortResult = [[BlinkUpPluginResult alloc] init];
    abortResult.state = Error;
    [abortResult setPluginError:CANCELLED_BY_USER];
    
    CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:[abortResult getCordovaStatus] messageAsString: [abortResult getResults]];
    [self.commandDelegate sendPluginResult:cordovaResult callbackId:command.callbackId];

}

/*********************************************************
 * shows default UI for BlinkUp process. Modify this method
 * if you wish to use a custom UI (refer to API docs)
 ********************************************************/
- (void) navigateToBlinkUpView {
    
    // load cached planID (if not cached yet, BlinkUp automatically generates a new one)
    NSString *planId = [[NSUserDefaults standardUserDefaults] objectForKey:@"planId"];
    
    // see electricimp.com/docs/manufacturing/planids/ for info about planIDs
    #ifdef DEBUG
        planId = (self.developerPlanId != "") ? self.developerPlanId : nil;
    #endif
    
    if (self.useCachedPlanId.boolValue) {
        self.blinkUpController = [[BUBasicController alloc] initWithApiKey:self.apiKey planId:planId];
    }
    else {
        self.blinkUpController = [[BUBasicController alloc] initWithApiKey:self.apiKey];
    }

    [self.blinkUpController presentInterfaceAnimated:YES
        resignActive: ^(BOOL willRespond, BOOL userDidCancel, NSError *error) {
            [self blinkUpDidComplete:willRespond userDidCancel:userDidCancel error:error];
        }
        devicePollingDidComplete: ^(BUDeviceInfo *deviceInfo, BOOL timedOut, NSError *error) {
            [self deviceRequestDidCompleteWithDeviceInfo:deviceInfo timedOut:timedOut error:error];
        }
    ];
}


/*********************************************************
 * Called when BlinkUp controller is closed, by user
 * cancelling, flashing process complete, or on error.
 * Sends status back to Cordova app.
 ********************************************************/
- (void) blinkUpDidComplete:(BOOL)willRespond userDidCancel:(BOOL)userDidCancel error:(NSError*)error {
    
    BlinkUpPluginResult *pluginResult = [[BlinkUpPluginResult alloc] init];

    if (willRespond) {
        // can't set timeout manually, so just tell devicePoller to stop polling (if timeout not default)
        long timeoutInMs = self.timeoutInMs.longValue;
        if (timeoutInMs != 60000) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeoutInMs * NSEC_PER_MSEC),
                dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self.blinkUpController.devicePoller stopPolling];
                    [self deviceRequestDidCompleteWithDeviceInfo:nil timedOut:true error:nil];
            });
        }
        pluginResult.state = Started;
        pluginResult.statusCode = GATHERING_INFO;
    }
    else if (userDidCancel) {
        pluginResult.state = Error;
        pluginResult.state = CANCELLED_BY_USER;
    }
    else if (error != nil) {
        pluginResult.state = Error;
        [pluginResult setBlinkUpError: error];
    }
    else {
        pluginResult.state = Completed;
        pluginResult.statusCode = CLEAR_COMPLETE;
    }
    
    //send results
    CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:[pluginResult getCordovaStatus] messageAsString:[pluginResult getResults]];
    [cordovaResult setKeepCallbackAsBool: [pluginResult getKeepCallback]];
    [self.commandDelegate sendPluginResult:cordovaResult callbackId:self.callbackId];
}


/*********************************************************
 * Called when device info has been loaded from Electric
 * Imp server, or when that request timed out.
 * Sends device info and status back to Cordova app.
 ********************************************************/
- (void) deviceRequestDidCompleteWithDeviceInfo:(BUDeviceInfo*)deviceInfo timedOut:(BOOL)timedOut error:(NSError*)error {
    
    BlinkUpPluginResult *pluginResult = [[BlinkUpPluginResult alloc] init];

    if (timedOut) {
        pluginResult.state = Error;
        [pluginResult setPluginError:PROCESS_TIMED_OUT];
    }
    else if (error != nil) {
        pluginResult.state = Error;
        [pluginResult setBlinkUpError:error];
    }
    else {
        // cache plan ID (see electricimp.com/docs/manufacturing/planids/)
        [[NSUserDefaults standardUserDefaults] setObject:deviceInfo.planId forKey:@"planId"];
        
        pluginResult.state = Completed;
        pluginResult.statusCode = DEVICE_CONNECTED;
        pluginResult.deviceInfo = deviceInfo;
    }
    
    //send results
    CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:[pluginResult getCordovaStatus] messageAsString:[pluginResult getResults]];
    [cordovaResult setKeepCallbackAsBool: [pluginResult getKeepCallback]];
    [self.commandDelegate sendPluginResult:cordovaResult callbackId:self.callbackId];
}

@end
