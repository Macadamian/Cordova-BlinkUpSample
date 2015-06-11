if [ -z "$1" ]; then
echo "You must pass your BlinkUp API key as an argument to this script."
exit
fi

sed -i '.bak' "s/YOUR_API_KEY_HERE/$1/g" www/js/index.js
rm www/js/index.js.bak

sed -i '.bak' "s/YOUR_API_KEY_HERE/$1/g" platforms/android/assets/www/js/index.js
rm platforms/android/assets/www/js/index.js.bak

sed -i '.bak' "s/YOUR_API_KEY_HERE/$1/g" platforms/ios/www/js/index.js
rm platforms/ios/www/js/index.js.bak
