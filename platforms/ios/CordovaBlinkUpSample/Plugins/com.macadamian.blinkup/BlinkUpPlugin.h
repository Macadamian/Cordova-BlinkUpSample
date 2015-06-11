#import <Cordova/CDV.h>

@interface BlinkUpPlugin : CDVPlugin

//------------------------------------------------------
// Shows BlinkUp UI for user to enter wifi details and
// perform the screen flash process to connect to an Imp
//------------------------------------------------------
- (void)invokeBlinkUp:(CDVInvokedUrlCommand*)command;

@end
