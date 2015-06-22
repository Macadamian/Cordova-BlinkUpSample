# Cordova-BlinkUpSample
Sample application that demonstrates how to use Electric Imp's BlinkUp SDK in Cordova applications for iOS and Android.

Electric Imp is an Internet of Things platform used from prototyping to production. For more information about Electric Imp, visit: https://electricimp.com/. 

# Pre-requisistes
An Electric Imp Board development kit. For more information on how to obtain a development kit, please visit: https://electricimp.com/docs/gettingstarted/devkits/ 

An Electric Imp developer account. To register for an account, please visit: https://ide.electricimp.com/

A BlinkUp SDK and API Key. For more information on how to obtain a license, please visit: https://electricimp.com/docs/manufacturing/blinkup_faqs/

# Installation
Open `CordovaBlinkUpSample/www/js/index.js` and set your API key from Electric Imp. You can optionally set your plan ID as well, this will let you see Imps you've blinked up with in your IDE. Please see https://electricimp.com/docs/manufacturing/planids/ for more information about plan ID's.

When building in Xcode or Android Studio, this `index.js` file overwrites the native platform's `index.js` file, propagating your changes down to both platforms.

**iOS Instructions**<br>
Copy the `BlinkUp.embeddedframework` folder to `path/to/Cordova-BlinkUpSample/platforms/ios/CordovaBlinkUpSample/Frameworks` folder.

**Android Instructions**<br>
Copy the `blinkup_sdk` folder from the BlinkUp SDK to `path/to/Cordova-BlinkUpSample/platforms/android`. 

# Project Structure
Refer to `www/index.js` for an example of how to call the plugin that initiates the native BlinkUp process. 

The native code that interfaces with the plugin (and sends back the device info) can be found at `platforms/android/src/com/macadamian/blinkup` and `platforms/ios/CordovaBlinkUpExample/Plugins/com.macadamian.blinkup`.
