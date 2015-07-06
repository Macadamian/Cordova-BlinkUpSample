cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/com.macadamian.blinkup/www/blinkup.js",
        "id": "com.macadamian.blinkup.blinkup",
        "clobbers": [
            "blinkup"
        ]
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/tests.js",
        "id": "cordova-plugin-test-framework.cdvtests"
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/jasmine_helpers.js",
        "id": "cordova-plugin-test-framework.jasmine_helpers"
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/medic.js",
        "id": "cordova-plugin-test-framework.medic"
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/main.js",
        "id": "cordova-plugin-test-framework.main"
    },
    {
        "file": "plugins/com.macadamian.blinkup-tests/tests.js",
        "id": "com.macadamian.blinkup-tests.tests"
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-whitelist": "1.0.0",
    "com.macadamian.blinkup": "0.1",
    "cordova-plugin-test-framework": "1.0.2-dev",
    "com.macadamian.blinkup-tests": "0.1"
}
// BOTTOM OF METADATA
});