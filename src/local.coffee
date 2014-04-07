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
 	<a class='item bucket bucket-bg' style="background-image: url('#{ad.image}'); background-position: center;" data-id="#{ad.id}" href="#" onclick="getAdWithGPS();">
 		<div class="row no-padding">
 			<div class="col col-50 bucket-name"> #{ad.updated_ago} </div>
 			<div class="col col-50 bucket-name"> #{ad.business_name} &middot #{ad.distance}m</div>
 		</div>
 	<div style="height: 65px;"> </div>
 	<p class="bucket-tag-container">
 """)
)

Handlebars.registerHelper('createTag', (tag)->
	new Handlebars.SafeString("""
	<button disabled class="button button-outline button-small button-stable bucket-tag">#{tag}</button>
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
	window.plugins.socialsharing.share(
		"Hey, check out #{$('div#business-info')[0].textContent.trim()} away from me right now: #{$('p#business-caption')[0].textContent.trim()} #Уonder!", 'Уonder!',
		$('.bucket-bg')[0].style.backgroundImage.slice(4, -1)
	)

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

getPass = (id)-> 
	$.get("http:scupr-staging.herokuapp.com/pass/#{id}", (data)->
 	Passbook.downloadPass(data.pass_url)
 	)

getCoupon = (id)-> 
	$.get("http:scupr-staging.herokuapp.com/coupon/#{id}", (data)->
 	Passbook.downloadPass(data.pass_url)
 	)

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
