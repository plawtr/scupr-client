// Generated by CoffeeScript 1.7.1
var getBusinessMapWithGPS, getMapWithGPS, mapStyle, onBusinessGPSSuccess, onGPSSuccess;

mapStyle = [
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#165c64"
      }, {
        "saturation": 34
      }, {
        "lightness": -69
      }, {
        "visibility": "on"
      }
    ]
  }, {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#b7caaa"
      }, {
        "saturation": -14
      }, {
        "lightness": -18
      }, {
        "visibility": "on"
      }
    ]
  }, {
    "featureType": "landscape.man_made",
    "elementType": "all",
    "stylers": [
      {
        "hue": "#cbdac1"
      }, {
        "saturation": -6
      }, {
        "lightness": -9
      }, {
        "visibility": "on"
      }
    ]
  }, {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#8d9b83"
      }, {
        "saturation": -89
      }, {
        "lightness": -12
      }, {
        "visibility": "on"
      }
    ]
  }, {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#d4dad0"
      }, {
        "saturation": -88
      }, {
        "lightness": 54
      }, {
        "visibility": "simplified"
      }
    ]
  }, {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#bdc5b6"
      }, {
        "saturation": -89
      }, {
        "lightness": -3
      }, {
        "visibility": "simplified"
      }
    ]
  }, {
    "featureType": "road.local",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#bdc5b6"
      }, {
        "saturation": -89
      }, {
        "lightness": -26
      }, {
        "visibility": "on"
      }
    ]
  }, {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#c17118"
      }, {
        "saturation": 61
      }, {
        "lightness": -45
      }, {
        "visibility": "on"
      }
    ]
  }, {
    "featureType": "poi.park",
    "elementType": "all",
    "stylers": [
      {
        "hue": "#8ba975"
      }, {
        "saturation": -46
      }, {
        "lightness": -28
      }, {
        "visibility": "on"
      }
    ]
  }, {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#a43218"
      }, {
        "saturation": 74
      }, {
        "lightness": -51
      }, {
        "visibility": "simplified"
      }
    ]
  }, {
    "featureType": "administrative.province",
    "elementType": "all",
    "stylers": [
      {
        "hue": "#ffffff"
      }, {
        "saturation": 0
      }, {
        "lightness": 100
      }, {
        "visibility": "simplified"
      }
    ]
  }, {
    "featureType": "administrative.neighborhood",
    "elementType": "all",
    "stylers": [
      {
        "hue": "#ffffff"
      }, {
        "saturation": 0
      }, {
        "lightness": 100
      }, {
        "visibility": "off"
      }
    ]
  }, {
    "featureType": "administrative.locality",
    "elementType": "labels",
    "stylers": [
      {
        "hue": "#ffffff"
      }, {
        "saturation": 0
      }, {
        "lightness": 100
      }, {
        "visibility": "off"
      }
    ]
  }, {
    "featureType": "administrative.land_parcel",
    "elementType": "all",
    "stylers": [
      {
        "hue": "#ffffff"
      }, {
        "saturation": 0
      }, {
        "lightness": 100
      }, {
        "visibility": "off"
      }
    ]
  }, {
    "featureType": "administrative",
    "elementType": "all",
    "stylers": [
      {
        "hue": "#3a3935"
      }, {
        "saturation": 5
      }, {
        "lightness": -57
      }, {
        "visibility": "off"
      }
    ]
  }, {
    "featureType": "poi.medical",
    "elementType": "geometry",
    "stylers": [
      {
        "hue": "#cba923"
      }, {
        "saturation": 50
      }, {
        "lightness": -46
      }, {
        "visibility": "on"
      }
    ]
  }
];

onGPSSuccess = function(position) {
  var businessLocation, directionsDisplay, directionsService, map, myOptions, request, userLocation;
  userLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
  businessLocation = new google.maps.LatLng(window.businessLat, window.businessLng);
  directionsDisplay = new google.maps.DirectionsRenderer();
  myOptions = {
    zoom: 16,
    center: userLocation,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    styles: mapStyle,
    disableDefaultUI: true
  };
  directionsService = new google.maps.DirectionsService();
  map = new google.maps.Map(document.getElementById("map"), myOptions);
  directionsDisplay.setMap(map);
  request = {
    origin: userLocation,
    destination: businessLocation,
    travelMode: google.maps.TravelMode.WALKING
  };
  return directionsService.route(request, function(response, status) {
    if (status === google.maps.DirectionsStatus.OK) {
      return directionsDisplay.setDirections(response);
    }
  });
};

getMapWithGPS = function() {
  var mapCanvas;
  mapCanvas = $("<div class=\"list card\">\n    <div class=\"item item-image\" id=\"map\" style=\"width: 100%; height: 300px\">\n    </div>\n</div>");
  $('#placeholder').html(mapCanvas);
  window.businessLng = $(this.event.target).data('lng');
  window.businessLat = $(this.event.target).data('lat');
  return navigator.geolocation.getCurrentPosition(onGPSSuccess, onGPSError);
};

getBusinessMapWithGPS = function() {
  var mapCanvas;
  mapCanvas = $("<div class=\"list card\">\n    <div class=\"item item-image\" id=\"map\" style=\"width: 100%; height: 300px\">\n    </div>\n</div>");
  $('#placeholder').html(mapCanvas);
  window.businessLng = $(this.event.target).data('lng');
  window.businessLat = $(this.event.target).data('lat');
  return navigator.geolocation.getCurrentPosition(onBusinessGPSSuccess, onGPSError);
};

onBusinessGPSSuccess = function(position) {
  var businessLocation, map, marker, myOptions;
  businessLocation = new google.maps.LatLng(window.businessLat, window.businessLng);
  myOptions = {
    zoom: 16,
    center: businessLocation,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    styles: mapStyle,
    disableDefaultUI: true
  };
  map = new google.maps.Map(document.getElementById("map"), myOptions);
  marker = new google.maps.Marker({
    position: businessLocation,
    draggable: true,
    map: map
  });
  return google.maps.event.addListener(marker, 'dragend', function(evt) {
    document.getElementById('business-lat').value = evt.latLng.lat();
    return document.getElementById('business-lng').value = evt.latLng.lng();
  });
};
