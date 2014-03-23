angular.module('scupr', ['ionic'])

startApp = ()->
	getBucketWithGPS()
	
onLoad = ()->
	document.addEventListener("deviceready", onDeviceReady, false)

getBucket = (position)->
	$.get("http://scupr-staging.herokuapp.com/ads", position, (data)->
 	fillBucket(data)
 	)

getAd = (position) ->
	$.get("http://scupr-staging.herokuapp.com/ads/#{window.currentAdId}", position, (data) ->
 	fillAd(data))

fillBucket = (data)->
	source = $("#bucket-template").html()
	template = Handlebars.compile(source)
	$('#bucket').html(template(roundDistanceForAds(data)))

fillAd = (data)->
	source = $("#ad-template").html()
	template = Handlebars.compile(source)
	$('#bucket').html(template(roundDistanceOfAd(data)))
	window.scrollTo(0,0)

Handlebars.registerHelper('createBucket', (ad)->
	new Handlebars.SafeString("""
	<a class='item item-thumbnail-left' data-id="#{ad.id}" href="#" onclick="getAdWithGPS();">
 <img src= "#{ad.bucket_image}"/>
 <h2>#{ad.business_name} &middot #{ad.distance}m</h2>
 <p>#{ad.caption}</p>
 </a>
 """)
)

getBucketWithGPS = ()->
	navigator.geolocation.getCurrentPosition(onGPSBucketSuccess, onGPSError)

getAdWithGPS = ()->
	window.currentAdId = $(this.event.target).data('id')
	navigator.geolocation.getCurrentPosition(onGPSAdSuccess, onGPSError)

onGPSBucketSuccess = (position)->
	getBucket(position)
	# alert('Latitude: ' + position.coords.latitude + '\n' + 'Longitude: ' + position.coords.longitude + '\n' + 'Altitude: ' + position.coords.altitude + '\n' + 'Accuracy: ' + position.coords.accuracy + '\n' + 'Altitude Accuracy: ' + position.coords.altitudeAccuracy + '\n' + 'Heading: ' + position.coords.heading + '\n' + 'Speed: ' + position.coords.speed + '\n' + 'Timestamp: ' + position.timestamp + '\n')

onGPSAdSuccess = (position) ->
	getAd(position)

onGPSError = (error)-> 
	alert('code: ' + error.code + '\n' + 'message: ' + error.message + '\n')

roundDistanceForAds = (data)->
	ad.distance = Math.round(ad.distance*1000) for ad in data.ads 
	data

roundDistanceOfAd = (data)->
	data.ad.distance = Math.round(data.ad.distance*1000)
	data

# window.addEventListener("statusTap", ()->
# 	alert("status tap")
# 	document.body.scrollTop = 0
# 	window.scrollTo(0,0)
# )

getBusinessForm = ()->
	source = $("#form-template").html()
	template = Handlebars.compile(source)
	$('#bucket').html(template())

postNewBusiness = ()-> 	
	alert('submiting')
	event.preventDefault()
	params = $('#new-business').serializeArray()
	console.log(params)
	$.post("http://0.0.0.0:3000/business/new", params, successPost(), "json")

successPost = ()->
	alert("sending data")

pictureFail = (message)->
	alert("sending data")
 
selectPhoto = ()->
	navigator.camera.getPicture(uploadPhoto, pictureFail(message), 
		{
      quality         : 50,
      destinationType : navigator.camera.DestinationType.FILE_URI,
      sourceType      : navigator.camera.PictureSourceType.PHOTOLIBRARY
	  }
  )

uploadPhoto = (imageURI)-> 
  options = new FileUploadOptions()
  options.fileKey="file"
  options.fileName=imageURI.substr(imageURI.lastIndexOf('/')+1)
  options.mimeType="image/jpeg"

  params = {}
  params.value1 = "test"
  params.value2 = "param"

  options.params = params

  ft = new FileTransfer()
  ft.upload(imageURI, encodeURI("http://0.0.0.0:3000/business/new"), win, fail, options)

win = (r)->
  console.log("Code = " + r.responseCode)
  console.log("Response = " + r.response)
  console.log("Sent = " + r.bytesSent)

fail = (error)->
  alert("An error has occurred: Code = " + error.code)
  console.log("upload error source " + error.source)
  console.log("upload error target " + error.target)

