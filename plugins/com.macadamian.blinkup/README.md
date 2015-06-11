Installation
==============

**STEP 1**<br>
Navigate to your project directory and install the plugin with `cordova add plugin /path/to/plugin`. Add both platforms with `cordova platform add ios` and `cordova platform add android`.

iOS
--------------
Open `/path/to/project/platforms/ios/<ProjectName>.xcodeproj` in Xcode and choose File > Add Files to Project. Select the `BlinkUp.framework` file given to you by Electric Imp, and ensure that both "*Copy items if needed*" and "*Add to targets: <ProjectName>*" are selected. Do the same for `BlinkUp.framework/resources/versions/A/BlinkUp.bundle`.


Android
--------------
**STEP 1**<br>
Copy the `blinkup_sdk` folder from the SDK package given to you by Electric Imp to `/path/to/project/platforms/android/`.

**STEP 2**<br>
Open `path/to/project/platforms/android/cordova/lib/build.js` and add the following line to the `fs.writeFileSync(path.join(projectPath, 'settings.gradle')` function (line 251):
```
'include ":blinkup_sdk"\n' +
```
It should now look like this:
```
...
// Write the settings.gradle file.
fs.writeFileSync(path.join(projectPath, 'settings.gradle'),
    '// GENERATED FILE - DO NOT EDIT\n' +
    'include ":"\n' +
    'include ":blinkup_sdk"\n' +
    'include "' + subProjectsAsGradlePaths.join('"\ninclude "') + '"\n');
// Update dependencies within build.gradle.
...
```

**STEP 3**<br>
Open `MainActivity.java`. If your project is *com.company.project* then it's located in `platforms/android/src/com/company/project`. Add the following imports:
```
import android.content.Intent;
import com.macadamian.blinkup.Globals;
```
And the following method:
```
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
    super.onActivityResult(requestCode, resultCode, intent);
    Globals.blinkUpController.handleActivityResult(this, requestCode, resultCode, intent);
}
```
If you do not do this step, the BlinkUp controller will still function properly, but you will not receive the infomation passed to the callback (the status of the blinkUp, device ID, etc).

**STEP 4**<br>
Navigate to your project root directory and run `cordova build android`. You only need to do this once, then you can run the project directly from Android Studio. To use Android Studio, select "Open Existing Project" and select the `path/to/project/platforms/android` folder. Press OK when prompted to generate a Gradle wrapper.

**STEP 5** (Optional)<br>
Open `android/manifests/AndroidManifest.xml` and add the following property to the application tag:
```
android:theme="@style/android:Theme.Holo.Light"
```

Using the Plugin
==========
Open `www/index.js` and add the following to the end of `onDeviceReady` (you *need* to fill in your BlinkUp API key given by Electric Imp or the plugin won't work)
```
var success = function (message) {
    try {
        var jsonData = JSON.parse("(" + message + ")");
        var status   = jsonData.status   != null ? jsonData.status   : "";
        var planId   = jsonData.planId   != null ? jsonData.planId   : "";
        var deviceId = jsonData.deviceId != null ? jsonData.deviceId : "";
        var agentURL = jsonData.agentURL != null ? jsonData.agentURL : "";
    } catch (exception) {
        var status = message;
    }
};

var failure = function (message) {
    try {
        var jsonData = JSON.parse("(" + message + ")");
        var status = jsonData.status != null ? jsonData.status : "";
    } catch (exception) {
        var status = message;
    }
};

// if you want to reset the device whenever the user Blinks Up, set this to false
// see https://electricimp.com/docs/manufacturing/planids/ for more info
var useCachedPlanId = true; 

var timeoutMs = 60000; // default is 1 minute

blinkup.initiateBlinkUp("YOUR_API_KEY_HERE", timeoutMs, useCachedPlanId, success, failure);
```

Testing the Plugin
-----------
If you are testing devices for development, you can override the planID with your own developer planID to see the Imps in the Electric Imp IDE. For iOS you'll find it in `BlinkUp.m` -> `presentBlinkUp()`. On Android, it's at `BlinkUp.java` -> `presentBlinkUp()`.<br>

IMPORTANT NOTE: if a developer planId makes it into production, the consumer's device will not configure. Please read http://electricimp.com/docs/manufacturing/planids/ for more info.
