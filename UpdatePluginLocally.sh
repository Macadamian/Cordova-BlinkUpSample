#!/bin/bash

#====================================
# Overwrites native files from plugin
# with latest from your local directory
# WARNING: Do not commit in the sample application!
#====================================


#---------------------------
# confirm before continuing
#---------------------------
echo
read -p "Updating the plugin will overwrite \
all native iOS and Android files.
****** WARNING: DO NOT commit the updated plugin! ******
Are you sure you wish to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo
    echo "Update cancelled by user, exiting now."
    exit 1
fi
echo

#---------------------------
# check cordova is installed
#---------------------------
if ! hash cordova 2>/dev/null; then
    echo "The Cordova CLI could not be found. 
Please see https://cordova.apache.org/docs/en/4.0.0/guide_cli_index.md.html \
for installation instructions."
    echo
    exit 1
fi

#---------------------------
# check plugin is installed in the same parent folder...
#---------------------------
if [ ! -d "../Cordova-BlinkUpPlugin" ]; then
    echo "The Cordova Plugin clone could not be found in the same parent directory."
    exit 1
fi

#---------------------------
# reinstall plugin locally. Expects it to be in the same parent folder.
#---------------------------
 cordova plugin rm com.macadamian.blinkup
 cordova plugin add "../Cordova-BlinkUpPlugin"

#---------------------------
# alert user to annoying bug
# in Xcode with fix
#---------------------------
echo
echo "*****************************************"
echo "NOTE: Sometimes running this script can remove the plugin files from\
 Xcode's 'Compile Sources' Build Phase. If the app is no longer working on iOS,\
 you may have to re-add BlinkUpPlugin.m and BlinkUpPluginResult.m to that section."
echo "****************************************"
echo
