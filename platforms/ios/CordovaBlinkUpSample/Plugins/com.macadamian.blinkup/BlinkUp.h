#import <Cordova/CDV.h>

// make sure you've linked to the BlinkUp framework in
// Build Phases -> "Link binary with libraries"
#import <BlinkUp/BlinkUp.h>

@interface BlinkUp : CDVPlugin

//------------------------------------------------------
// Shows BlinkUp UI for user to enter wifi details and
// perform the screen flash process to connect to an Imp
//------------------------------------------------------
- (void) initiateBlinkUp:(CDVInvokedUrlCommand*)command;

@end
