#import <Cordova/CDV.h>

@class BUBasicController;

@interface BlinkUpPlugin : CDVPlugin

//------------------------------------------------------
// Shows BlinkUp UI for user to enter wifi details and
// perform the screen flash process to connect to an Imp
//------------------------------------------------------
- (void)invokeBlinkUp:(CDVInvokedUrlCommand*)command;

// instance variables
@property BUBasicController  *blinkUpController;

@property NSString  *apiKey;
@property NSString *callbackId;
@property NSNumber *timeoutInMs;
@property NSNumber *useCachedPlanId;

@end
