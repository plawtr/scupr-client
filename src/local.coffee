angular.module('scupr', ['ionic'])

startApp = ()->
	getBucketWithGPS()
	
onLoad = ()->
	document.addEventListener("deviceready", onDeviceReady, false)

getBucket = (position)->
	$.get("http:scupr-staging.herokuapp.com/ads", position, (data)->
 	fillBucket(data)
 	)

getAd = (position) ->
	$.get("http:scupr-staging.herokuapp.com/ads/#{window.currentAdId}", position, (data) ->
 	fillAd(data))

fillBucket = (data)->
	source = $("#bucket-template").html()
	template = Handlebars.compile(source)
	$('#bucket').html(template(roundDistanceForAds(data)))
	window.scrollTo(0,0)

fillAd = (data)->
	source = $("#ad-template").html()
	template = Handlebars.compile(source)
	$('#bucket').html(template(roundDistanceOfAd(data)))
	window.scrollTo(0,0)

Handlebars.registerHelper('createBucket', (ad)->
	new Handlebars.SafeString("""
<a class='item item-thumbnail-left item-text-wrap' data-id="#{ad.id}" href="#" onclick="getAdWithGPS();">
 <img src= "#{ad.bucket_image}"/>
 <h2>#{ad.business_name} &middot #{ad.distance}m</h2>
 <p style="margin: 0 0 0px">#{ad.caption}</p>
 <p>#{ad.updated_ago} &middot
 """)
)

Handlebars.registerHelper('createTag', (tag)->
	new Handlebars.SafeString("""
	<button disabled style="line-height: 18px; min-height: 0px; margin-bottom: 3px;" class="button button-outline button-small button-positive">#{tag}</button>
 """)
)

Handlebars.registerHelper('closeItem', ()->
	new Handlebars.SafeString("""
	</p>
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
 
selectPhoto = ()->
	event.preventDefault()
	photoOptions = {
			quality         : 30,
			destinationType : navigator.camera.DestinationType.FILE_URI,
			sourceType      : navigator.camera.PictureSourceType.PHOTOLIBRARY
	}
	navigator.camera.getPicture(uploadPhoto, onPictureFail, photoOptions)

onPictureFail = (message)->
	event.preventDefault()
	console.log('Failed because: ' + message)

uploadPhoto = (imageURI)-> 
	spinnerplugin.show({'overlay':true})
	options = new FileUploadOptions()
	options.fileKey="file"
	options.fileName=imageURI.substr(imageURI.lastIndexOf('/')+1)
	options.mimeType="image/jpeg"

	params = {}
	params[input.name] = input.value for input in $("input")

	options.params = params

	ft = new FileTransfer()
	ft.upload(imageURI, encodeURI("http:scupr-staging.herokuapp.com/business/new"), onTransferSuccess, onTransferFail, options)

onTransferSuccess = (r)->
	spinnerplugin.hide()
	console.log("Code = " + r.responseCode)
	console.log("Response = " + r.response)
	console.log("Sent = " + r.bytesSent)
	window.localStorage.setItem("business", r.response)
	navigator.notification.alert("Successfully uploaded", getBucketWithGPS(), "Business and ad details")

onTransferFail = (error)->
	navigator.notification.alert("Code = " + error.code, $.noop, "An error has occurred")
	console.log("upload error source " + error.source)
	console.log("upload error target " + error.target)

shareAdSocially = ()->
	window.plugins.socialsharing.share("Hey, check out #{$('h2')[0].textContent} away from me right now: #{$('p')[0].textContent} #Уonder!", 'Уonder!', $('img')[0].src)

getBusinessForm = ()->
	navigator.geolocation.getCurrentPosition((position)->
		cookie = JSON.parse(window.localStorage.getItem("business"))
		noEmptyFieldsOrButtons = false
		if cookie == null 
			cookie = {
			business: 
				{
				radius: 500,
				lat: position.coords.latitude,
				lng: position.coords.longitude
				}
			}
			noEmptyFieldsOrButtons = true

		source = $("#form-template").html()
		template = Handlebars.compile(source)
		$('#bucket').html(template(cookie))

		$('#ad_tags').inputosaurus({
			width: '200px',
			allowDuplicates: false,
			inputDelimiters: [',', ';', ' '],
			outputDelimiter: [' '],
			# autoCompleteSource : ['alabama', 'illinois', 'kansas', 'kentucky', 'new york'],
			change : (ev)->
				$('#widget1_reflect').val(ev.target.value)
		})

		if noEmptyFieldsOrButtons == true 						# If the cookie is empty hide:
			$("#stripe")[0].style.display='none' 				# Stripe/increase radius button
			$(".item-divider")[2].style.display='none' 	# existing ad caption and image
			$(".item-thumbnail-left")[0].style.display='none' 
			$("#log-out")[0].style.display='none' 			# log out button
	, onGPSError)

killMeNow = ()->
	window.localStorage.setItem("business",  null)
	getBucketWithGPS()

getPassbook = ()-> 
	Passbook.downloadPass('https://s3.amazonaws.com/scupr/pass/new.pkpass')

getStripeForm = ()->
	event.preventDefault()
	source = $("#stripe-template").html()
	template = Handlebars.compile(source)
	$('#bucket').html(template())


getTagBucketWithGPS = (tag)->
	event.preventDefault()
	window.currentTag = $(this.event.target).data('tag')
	navigator.geolocation.getCurrentPosition(onGPSTagSuccess, onGPSError)

onGPSTagSuccess = (position) ->
	getTag(position)

getTag = (position)->
	$.get("http:scupr-staging.herokuapp.com/tags/#{window.currentTag}", position, (data)->
 	fillBucket(data)
 	)

getBusiness = (id)->
	$.get("http:scupr-staging.herokuapp.com/business/#{id}", (data)->
 	window.localStorage.setItem("business", JSON.stringify(data))
 	getBusinessForm()
 	)
