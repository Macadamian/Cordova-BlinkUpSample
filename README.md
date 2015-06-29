Cordova-BlinkUpSample
===========
Sample application that demonstrates how to use Electric Imp's BlinkUp SDK in Cordova applications for iOS and Android.

Electric Imp is an Internet of Things platform used from prototyping to production. For more information about Electric Imp, visit: https://electricimp.com/. 

Prerequisites
===========
An Electric Imp Board development kit. For more information on how to obtain a development kit, please visit: https://electricimp.com/docs/gettingstarted/devkits/ 

An Electric Imp developer account. To register for an account, please visit: https://ide.electricimp.com/

A BlinkUp SDK and API Key. For more information on how to obtain a license, please visit: https://electricimp.com/docs/manufacturing/blinkup_faqs/

Installation
===========
**IMPORTANT NOTE**<br>
Building the project with `cordova build <platform>` or `cordova run <platform>` will break the project. You must run from Xcode or Android Studio.
****

Open `CordovaBlinkUpSample/www/js/index.js` and set your API key from Electric Imp. You can optionally set your plan ID as well, this will let you see Imps you've blinked up with in your IDE. Please see https://electricimp.com/docs/manufacturing/planids/ for more information about plan ID's.

When building in Xcode or Android Studio, this `index.js` file overwrites the native platform's `index.js` file, propagating your changes down to both platforms.

**iOS Instructions**<br>
Copy the `BlinkUp.embeddedframework` folder to `path/to/Cordova-BlinkUpSample/platforms/ios/CordovaBlinkUpSample/Frameworks` folder.

**Android Instructions**<br>
Copy the `blinkup_sdk` folder from the BlinkUp SDK to `path/to/Cordova-BlinkUpSample/platforms/android`. 

Project Structure
===========
Refer to `www/index.js` for an example of how to call the plugin that initiates the native BlinkUp process. 

The native code that interfaces with the plugin (and sends back the device info) can be found at `platforms/android/src/com/macadamian/blinkup` and `platforms/ios/CordovaBlinkUpExample/Plugins/com.macadamian.blinkup`.

JSON Format
-----------
The plugin will return a JSON string in the following format to the callback set in `www/index.js` (this is `blinkupCallback` for Cordova-BlinkUpSample). Footnotes in square brackets.
```
{
    "state": "started" | "completed" | "error", [1]
    "statusCode": "",                           [2]
    "error": {                                  [3]
        "errorType": "plugin" | "blinkup",      [4]
        "errorCode": "",                        [5]
        "errorMsg": ""                          [6]
    },
    "deviceInfo": {                             [7]
        "deviceId": "",
        "planId": "",
        "agentURL": "",
        "verificationDate": ""
    }
 }
```
[1] - *started*: flashing process has finished, waiting for device info from Electric Imp servers<br>
*completed*: Plugin done executing. This could be a clear-wifi completed or device info from servers has arrived<br>
[2] - Status of plugin. Null if state is "error". See "Status Codes" below for status codes.<br>
[3] - Stores error information if state is "error". Null if state is "started" or "completed".<br>
[4] - If error sent from SDK, "blinkup". If error handled within native code of plugin, "plugin".<br>
[5] - BlinkUp SDK error code if errorType is "blinkup". Custom error code if "plugin". See "Error Codes" below for custom error codes.<br>
[6] - If errorType is "blinkup", error message from BlinkUp SDK. Null if errorType "plugin".<br>
[7] - Stores the device info from the Electric Imp servers. Null if state is "started" or "error".

Status Codes
-----------
These codes can be used to debug your application, or to present the users an appropriate message on success.
```
0   - "Device Connected"
200 - "Gathering device info..."
201 - "Wireless configuration cleared."
202 - "Wireless configuration and cached Plan ID cleared."
```

Error Codes
----------
IMPORTANT NOTE: the following codes apply ONLY if `errorType` is "plugin". Errors from the BlinkUp SDK will have their own error codes (which may overlap with those below). If `errorType` is "blinkup", you must use the `errorMsg` field instead. The errors in the 300's range are android only.
```
100 - "Invalid arguments in call to invokeBlinkUp."
101 - "Could not gather device info. Process timed out."
102 - "Process cancelled by user."
300 - "Invalid API key. You must set your BlinkUp API key in www/index.js." 
301 - "Could not verify API key with Electric Imp servers."
302 - "Error generating JSON string."
```

