package com.macadamian.blinkup;

import org.apache.cordova.CallbackContext;
import com.electricimp.blinkup.BlinkupController;

/**************************************
 * stores several objects required
 * by multiple classes in application
 *************************************/
public class Globals {
    public static CallbackContext callbackContext;
    public static BlinkupController blinkUpController;
    public static int timeoutMs = 60000; // default is 1 minute
}
