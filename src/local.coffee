angular.module('scupr', ['ionic'])

onLoad = () ->
	# alert("Device Loading")
	document.addEventListener("deviceready", onDeviceReady, false)
# device APIs are available

onDeviceReady = () ->
        # alert("Device Ready")
        getBucket()

getBucket = () ->
	# alert("get bucket!")
	$.get("http://scupr-staging.herokuapp.com/ads", (data) ->
  	fillBucket(data))

fillBucket = (data)->
	# alert("fill bucket!")
	console.log(data)
	source   = $("#bucket-template").html()
	console.log(source)
	template = Handlebars.compile(source)
	console.log(template)
	$('#bucket').html(template(data))

Handlebars.registerHelper('createBucket', (ads)->
	console.log(ads)
	out = ""
	for ad, i in ads
		console.log(ad)
		console.log(i)
		column ="""
		<div class="col card">
			<a href="#">
				<div class="item item-image">
					<img src= "#{ad.bucket_image}"/>
				</div>
			</a>
		</div>
		""" 
		if i % 4 == 0 
			out = out + "<div class='row'>#{column}"
		if i % 4 == 1 || i % 4 == 2
			out = out + column 
		if i % 4 == 3 
			out = out + ("#{column}</div>")

	new Handlebars.SafeString(out)
)