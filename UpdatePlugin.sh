#!/bin/bash

#====================================
# Overwrites native files from plugin
# with latest from plugin repo
#====================================


#---------------------------
# confirm before continuing
#---------------------------
echo
read -p "Updating the plugin will overwrite \
all native iOS and Android files.
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
# reinstall plugin from repo
#---------------------------
cordova plugin rm com.macadamian.blinkup
cordova plugin add cordova-blinkup-plugin
