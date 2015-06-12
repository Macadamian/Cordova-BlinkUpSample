# Cordova-BlinkUpSample
Sample application that demonstrates how to use Electric Imp's BlinkUp SDK in Cordova applications for iOS and Android.

Electric Imp is an Internet of Things platform used from prototyping to production. For more information about Electric Imp, visit: https://electricimp.com/. 

# Pre-requisistes
An Electric Imp Board development kit. For more information on how to obtain a development kit, please visit: https://electricimp.com/docs/gettingstarted/devkits/ 

An Electric Imp developer account. To register for an account, please visit: https://ide.electricimp.com/

A BlinkUp SDK and API Key. For more information on how to obtain a license, please visit: https://electricimp.com/docs/manufacturing/blinkup_faqs/

# Installation
**Both Platforms**<br>
Run the `SetApiKey.sh` script with your BlinkUp API key as an argument. E.g: `./SetApiKey.sh this_is_my_api_key`.

**iOS**<br>
Open `platforms/ios/CordovaBlinkUp.xcodeproj` in Xcode and select the Frameworks group in project navigator. Choose File > Add Files and select the `BlinkUp.framework` file included in the BlinkUp SDK, making sure "Copy items if needed" is selected. Do the same for `BlinkUp.bundle`, found in `BlinkUp.framework/resources/versions/A`. 

If you wish to link to these resources without copying them into the project directory, you will need to remove "Check For BlinkUp SDK" from the Xcode project's build phases.

**Android**<br>
Copy the `blinkup_sdk` folder from the BlinkUp SDK to `path/to/project/platforms/android`. 

# Project Structure
Refer to `www/index.js` for an example of how to call the plugin that initiates the native BlinkUp process. 

The native code that interfaces with the plugin (and sends back the device info) can be found at `platforms/android/src/com/macadamian/blinkup` and `platforms/ios/CordovaBlinkUpExample/Plugins/com.macadamian.blinkup`.
