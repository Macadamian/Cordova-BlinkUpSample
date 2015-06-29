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

NSString * const PLAN_ID_CACHE_KEY = @"planId";

// status codes
typedef NS_ENUM(NSInteger, BlinkUpStatusCodes) {
    DEVICE_CONNECTED              = 0,
    GATHERING_INFO                = 200,
    CLEAR_WIFI_COMPLETE           = 201,
    CLEAR_WIFI_AND_CACHE_COMPLETE = 202
};

// error codes
typedef NS_ENUM(NSInteger, BlinkUpErrorCodes) {
    INVALID_ARGUMENTS   = 100,
    PROCESS_TIMED_OUT   = 101,
    CANCELLED_BY_USER   = 102,
};

typedef NS_ENUM(NSInteger, BlinkupArguments) {
    BlinkUpArgumentApiKey = 0,
    BlinkUpArgumentPlanId,
    BlinkUpArgumentTimeOut,
    BlinkUpArgumentGeneratePlanId
};

@implementation BlinkUpPlugin

/*********************************************************
 * Parses arguments from javascript and displays BlinkUp
 ********************************************************/
- (void)invokeBlinkUp:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;

    if (command.arguments.count <= BlinkUpArgumentGeneratePlanId) {
        BlinkUpPluginResult *pluginResult = [[BlinkUpPluginResult alloc] init];
        pluginResult.state = Error;
        [pluginResult setPluginError:INVALID_ARGUMENTS];

        [self sendResultToCallback:pluginResult];
        return;
    }

    self.apiKey = [command.arguments objectAtIndex:BlinkUpArgumentApiKey];
    self.developerPlanId = [command.arguments objectAtIndex:BlinkUpArgumentPlanId];
    self.timeoutMs = [[command.arguments objectAtIndex:BlinkUpArgumentTimeOut] integerValue];
    self.generatePlanId = [[command.arguments objectAtIndex:BlinkUpArgumentGeneratePlanId] boolValue];

    [self navigateToBlinkUpView];
}

/*********************************************************
 * Cancels device polling
 ********************************************************/
- (void)abortBlinkUp:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;

    [self.blinkUpController.devicePoller stopPolling];
    self.blinkUpController = nil;

    BlinkUpPluginResult *abortResult = [[BlinkUpPluginResult alloc] init];
    abortResult.state = Error;
    [abortResult setPluginError:CANCELLED_BY_USER];
    
    [self sendResultToCallback:abortResult];
}

/********************************************************
 * Clears wifi configuration of Imp and cached planId
 ********************************************************/
- (void) clearBlinkUpData:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;

    // clear cached planId
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PLAN_ID_CACHE_KEY];

    // create a controller to clear network info
    BUNetworkConfig *clearConfig = [BUNetworkConfig clearNetworkConfig];
    BUFlashController *flashController = [[BUFlashController alloc] init];

    // present the clear device flashing screen
    [flashController presentFlashWithNetworkConfig:clearConfig configId:nil animated:YES resignActive:
    ^(BOOL willRespond, BUDevicePoller *devicePoller, NSError *error) {
        [self blinkUpDidComplete:false userDidCancel:false error:nil clearedCache:true];
    }];
}


/*********************************************************
 * shows default UI for BlinkUp process. Modify this method
 * if you wish to use a custom UI (refer to API docs)
 ********************************************************/
- (void) navigateToBlinkUpView {
    
    // load cached planID (if not cached yet, BlinkUp automatically generates a new one)
    NSString *planId = [[NSUserDefaults standardUserDefaults] objectForKey:PLAN_ID_CACHE_KEY];

    // see electricimp.com/docs/manufacturing/planids/ for info about planIDs
    #ifdef DEBUG
        planId = (self.developerPlanId != "") ? self.developerPlanId : nil;
    #endif
    
    if (self.generatePlanId || planId == nil) {
        self.blinkUpController = [[BUBasicController alloc] initWithApiKey:self.apiKey];
    }
    else {
        self.blinkUpController = [[BUBasicController alloc] initWithApiKey:self.apiKey planId:planId];
    }

    [self.blinkUpController presentInterfaceAnimated:YES
        resignActive: ^(BOOL willRespond, BOOL userDidCancel, NSError *error) {
            [self blinkUpDidComplete:willRespond userDidCancel:userDidCancel error:error clearedCache:false];
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
- (void) blinkUpDidComplete:(BOOL)willRespond userDidCancel:(BOOL)userDidCancel error:(NSError*)error clearedCache:(BOOL)clearedCache {
    
    BlinkUpPluginResult *pluginResult = [[BlinkUpPluginResult alloc] init];

    if (willRespond) {
        // can't set timeout manually, so just tell devicePoller to stop polling (if timeout not default)
        if (self.timeoutMs != 60000) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.timeoutMs * NSEC_PER_MSEC),
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
        [pluginResult setPluginError:CANCELLED_BY_USER];
    }
    else if (error != nil) {
        pluginResult.state = Error;
        [pluginResult setBlinkUpError: error];
    }
    else {
        pluginResult.state = Completed;
        if (clearedCache) {
        	pluginResult.statusCode = CLEAR_WIFI_AND_CACHE_COMPLETE;
        } 
        else {
        	pluginResult.statusCode = CLEAR_WIFI_COMPLETE;
    	}
    }
    
    [self sendResultToCallback:pluginResult];
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
        [[NSUserDefaults standardUserDefaults] setObject:deviceInfo.planId forKey:PLAN_ID_CACHE_KEY];
        
        pluginResult.state = Completed;
        pluginResult.statusCode = DEVICE_CONNECTED;
        pluginResult.deviceInfo = deviceInfo;
    }

    [self sendResultToCallback:pluginResult];
}

/*********************************************************
 * Creates a cordova plugin result from pluginResult with
 * correct settings and sends to callback
 ********************************************************/
- (void) sendResultToCallback:(BlinkUpPluginResult *)pluginResult {
    CDVPluginResult *cordovaResult = [CDVPluginResult resultWithStatus:[pluginResult getCordovaStatus] messageAsString:[pluginResult getResultsAsJsonString]];
    [cordovaResult setKeepCallbackAsBool: [pluginResult getKeepCallback]];
    [self.commandDelegate sendPluginResult:cordovaResult callbackId:self.callbackId];
}

@end
