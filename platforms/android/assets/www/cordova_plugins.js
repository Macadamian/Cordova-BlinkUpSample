cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/cordova-plugin-whitelist/whitelist.js",
        "id": "cordova-plugin-whitelist.whitelist",
        "runs": true
    },
    {
        "file": "plugins/com.macadamian.blinkup/www/blinkup.js",
        "id": "com.macadamian.blinkup.blinkup",
        "clobbers": [
            "blinkup"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-whitelist": "1.0.0",
    "com.macadamian.blinkup": "0.1"
}
// BOTTOM OF METADATA
});