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
        "file": "plugins/cordova-plugin-whitelist/whitelist.js",
        "id": "cordova-plugin-whitelist.whitelist",
        "runs": true
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "com.macadamian.blinkup": "0.1",
    "cordova-plugin-whitelist": "1.0.0"
}
// BOTTOM OF METADATA
});