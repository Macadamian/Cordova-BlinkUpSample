# Cordova-BlinkUpSample
Sample application that demonstrates how to use Electric Imp's BlinkUp SDK in Cordova applications for iOS and Android.

Electric Imp is an Internet of Things platform used from prototyping to production. For more information about Electric Imp, visit: https://electricimp.com/. 

# Pre-requisistes
An Electric Imp Board development kit. For more information on how to obtain a development kit, please visit: https://electricimp.com/docs/gettingstarted/devkits/ 

An Electric Imp developer account. To register for an account, please visit: https://ide.electricimp.com/

A BlinkUp SDK and API Key. For more information on how to obtain a license, please visit: https://electricimp.com/docs/manufacturing/blinkup_faqs/

**Both Platforms**<br>
Replace `"YOUR_API_KEY_HERE"` at the top of `www/index.js` and `platforms/ios/www/index.js` with your BlinkUp API key.

**iOS**<br>
Open `path/to/project/platforms/ios/<Project Name>.xcodeproj` in Xcode and select File > Add Files. Choose the `BlinkUp.framework` file included in the BlinkUp SDK and make sure "Copy items if needed" is selected. Do the same for `BlinkUp.framework/resources/versions/A/BlinkUp.bundle`.

**Android**<br>
Copy the `blinkup_sdk` folder from the BlinkUp SDK to `path/to/project/platforms/android`. 

# Project Structure
Insert Project Structure Discussion here.
