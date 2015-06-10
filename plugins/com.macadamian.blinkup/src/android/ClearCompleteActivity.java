package com.macadamian.blinkup;

import android.app.Activity;
import android.os.Bundle;

/*****************************************************
 * When the clearing BlinkUp process completes, it
 * executes the BlinkUpClearIntent set in BlinkUp.java,
 * starting this activity, which tells the callback
 * that clearing is complete, then dismisses
 ******************************************************/
public class ClearCompleteActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // send callback that we've cleared device
        Globals.callbackContext.success("Wireless configuration cleared.");

        this.finish();
    }
}
