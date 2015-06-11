package com.macadamian.blinkup;

import android.content.Intent;
import android.content.SharedPreferences;
import android.widget.Toast;
import android.content.pm.ApplicationInfo;
import org.json.JSONArray;
import org.json.JSONException;

import com.electricimp.blinkup.*;
import com.electricimp.blinkup.BuildConfig;

import org.apache.cordova.*;

/*********************************************
 * execute() called from Javascript interface,
 * which saves the arguments and presents the
 * BlinkUp interface from the SDK
 ********************************************/
public class BlinkUp extends CordovaPlugin {

    // Only needed in this class, so not in Globals
    private String apiKey;
    private Boolean useCachedPlanId = false;

    /**********************************************************
     * method called by Cordova javascript
     *********************************************************/
    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        if (action.equalsIgnoreCase("initiateBlinkUp")) {
            Globals.callbackContext = callbackContext;
            Globals.timeoutMs = data.getInt(1);
            this.apiKey = data.getString(0);
            this.useCachedPlanId = data.getBoolean(2);

            // default is to run on WebCore thread, we have UI so need UI thread
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    presentBlinkUp();
                }
            });
        }
        return true;
    }

    /**********************************************************
     * shows BlinkUp activity and handles appropriate callbacks
     *********************************************************/
    private void presentBlinkUp() {

        // show toast when token acquire succeeds or fails, but don't interrupt execution
        final BlinkupController.TokenAcquireCallback callback = new BlinkupController.TokenAcquireCallback() {
            @Override
            public void onSuccess(String planId, String id) {
                Toast.makeText(cordova.getActivity(), "Enrolment token acquired successfully", Toast.LENGTH_SHORT).show();
            }
            @Override
            public void onError(String s) {
                Toast.makeText(cordova.getActivity(), ("Error. " + s), Toast.LENGTH_SHORT).show();
            }
        };

        // send back error if connectivity issue
        BlinkupController.ServerErrorHandler errorHandler = new BlinkupController.ServerErrorHandler() {
            @Override
            public void onError(String s) {
                Globals.callbackContext.error("Error. Could not verify API key with Electric Imp servers.");
            }
        };

        // initialize controller
        Globals.blinkUpController = BlinkupController.getInstance();

        // load cached planId if available. Otherwise, SDK generates new one automatically
        if (useCachedPlanId) {
            SharedPreferences preferences = cordova.getActivity().getSharedPreferences("DefaultPreferences", cordova.getActivity().MODE_PRIVATE);
            String planId = preferences.getString("planId", null);
            Globals.blinkUpController.setPlanID(planId);
        }

        // set developerPlanId here to see device in Electric Imp IDE if in Debug Mode
        // see electricimp.com/docs/manufacturing/planids/ for info about planIDs
        if (0 != (cordova.getActivity().getApplicationInfo().flags &= ApplicationInfo.FLAG_DEBUGGABLE)) {
            String developerPlanId = null;
            Globals.blinkUpController.setPlanID(developerPlanId);
        }

        Globals.blinkUpController.acquireSetupToken(this.cordova.getActivity(), apiKey, callback);

        // onActivityResult called on MainActivity (i.e. cordova.getActivity()) when blinkup or clear
        // complete. It calls handleActivityResult on blinkupController, which initiates the following intents
        Globals.blinkUpController.intentBlinkupComplete = new Intent(this.cordova.getActivity(), BlinkUpCompleteActivity.class);
        Globals.blinkUpController.intentClearComplete = new Intent(this.cordova.getActivity(), ClearCompleteActivity.class);

        Globals.blinkUpController.selectWifiAndSetupDevice(this.cordova.getActivity(), this.apiKey, errorHandler);
    }
}