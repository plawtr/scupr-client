haml src/index.haml www/index.html
coffee -b --compile --output www/js/ src/
cordova build ios
cordova run ios