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

**iOS Instructions**<br>
Copy the `BlinkUp.embeddedframework` folder to `path/to/Cordova-BlinkUpSample/platforms/ios/CordovaBlinkUpSample/Frameworks` folder.

**Android Instructions**<br>
Copy the `blinkup_sdk` folder from the BlinkUp SDK to `path/to/Cordova-BlinkUpSample/platforms/android`. 

# Project Structure
Refer to `www/index.js` for an example of how to call the plugin that initiates the native BlinkUp process. 

The native code that interfaces with the plugin (and sends back the device info) can be found at `platforms/android/src/com/macadamian/blinkup` and `platforms/ios/CordovaBlinkUpExample/Plugins/com.macadamian.blinkup`.
