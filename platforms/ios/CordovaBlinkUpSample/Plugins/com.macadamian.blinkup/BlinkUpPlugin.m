#import "BlinkUpPlugin.h"
#import <BlinkUp/BlinkUp.h>

typedef NS_ENUM(NSInteger, BlinkupArguments) {
    BlinkUpArgumentApiKey = 0,
    BlinkUpArgumentTimeOut,
    BlinkUpUsedCachedPlanId,
};

@interface BlinkUpPlugin (Private)
@property BUBasicController  *blinkUpController;

@property NSString  *apiKey;
@property NSString *callbackId;
@property NSNumber *timeoutInMs;
@property NSNumber *useCachedPlanId;
@end

@implementation BlinkUpPlugin

/*********************************************************
 * Called by Javascript in Cordova application.
 * `command.arguments` is array, first item is apiKey
 ********************************************************/
- (void)invokeBlinkUp:(CDVInvokedUrlCommand*)command {

    self.callbackId = command.callbackId;
    
    if (command.arguments.count <= BlinkUpUsedCachedPlanId) {
        NSString *error = @"Error. Invalid argument count in call to invoke blink up(apiKey: String, timeoutMs: Integer, useCachedPlanId: Bool, success: Callback, failure: Callback)";
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    self.apiKey = [command.arguments objectAtIndex:BlinkUpArgumentApiKey];
    self.timeoutInMs = [command.arguments objectAtIndex:BlinkUpArgumentTimeOut];
    self.useCachedPlanId = [command.arguments objectAtIndex:BlinkUpUsedCachedPlanId];
    
    [self navigateToBlinkUpView];
}


/*********************************************************
 * shows default UI for BlinkUp process. Modify this method
 * if you wish to use a custom UI (refer to API docs)
 ********************************************************/
- (void) navigateToBlinkUpView {
    
    // load cached planID (if not cached yet, BlinkUp automatically generates a new one)
    NSString *planId = [[NSUserDefaults standardUserDefaults] objectForKey:@"planId"];
    
    // set your developer planId here to allow the imps to show up in the Electric Imp IDE
    // see electricimp.com/docs/manufacturing/planids/ for info about planIDs
    #ifdef DEBUG
        planId = nil;
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
    
    CDVCommandStatus status;
    NSString *resultMessage;;
    
    if (willRespond) {
        
        // since can't set timeout manually, we just tell devicePoller to stop polling (if timeout not default)
        long timeoutInMs = self.timeoutInMs.longValue;
        if (timeoutInMs != 60000) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeoutInMs * NSEC_PER_MSEC),
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                               [self.blinkUpController.devicePoller stopPolling];
                               [self deviceRequestDidCompleteWithDeviceInfo:nil timedOut:true error:nil];
                           });
        }

        // TODO: I want to isolate this in its own method
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"Gathering device info..." forKey:@"status"];
        [dict setValue:@"true" forKey:@"gatheringDeviceInfo"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];

        // TODO: memory isn't deallocated
        resultMessage = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        status = CDVCommandStatus_OK;
    }
    else if (userDidCancel) {
        resultMessage = @"Process cancelled by user.";
        status = CDVCommandStatus_ERROR;
    }
    else if (error != nil) {
        resultMessage = [@"Error. " stringByAppendingString:error.localizedDescription];
        status = CDVCommandStatus_ERROR;
    }
    else {
        resultMessage = @"Wireless configuration cleared.";
        status = CDVCommandStatus_OK;
    }
    
    // send result, and keep callback if gathering device info
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:status messageAsString:resultMessage];

    if (willRespond) {
        [result setKeepCallbackAsBool:YES];
    }

    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}


/*********************************************************
 * Called when device info has been loaded from Electric
 * Imp server, or when that request timed out.
 * Sends device info and status back to Cordova app.
 ********************************************************/
- (void) deviceRequestDidCompleteWithDeviceInfo:(BUDeviceInfo*)deviceInfo timedOut:(BOOL)timedOut error:(NSError*)error {
    
    CDVCommandStatus status;
    NSString *resultMessage;

    // TODO: move strings to resource file
    if (timedOut) {
        resultMessage = @"Error. Could not gather device info. Process timed out.";
        status = CDVCommandStatus_ERROR;
    }
    else if (error != nil) {
        resultMessage = [@"Error. " stringByAppendingString:error.localizedDescription];
        status = CDVCommandStatus_ERROR;
    }
    else {
        // cache plan ID (see electricimp.com/docs/manufacturing/planids/)
        [[NSUserDefaults standardUserDefaults] setObject:deviceInfo.planId forKey:@"planId"];

        // TODO isolate + create constants
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"Device Connected"             forKey:@"status"];
        [dict setValue:deviceInfo.planId               forKey:@"planId"];
        [dict setValue:deviceInfo.deviceId             forKey:@"deviceId"];
        [dict setValue:deviceInfo.agentURL.description forKey:@"agentURL"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        
        resultMessage = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        status = CDVCommandStatus_OK;
    }
    
    // send result, discard callback
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:status messageAsString:resultMessage];
    [result setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}

@end
