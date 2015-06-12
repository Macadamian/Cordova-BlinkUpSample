##
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Created by Stuart Douglas (sdouglas@macadamian.com) on June 11, 2015.
# Copyright (c) 2015 Macadamian. All rights reserved.
##


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
