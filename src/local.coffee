angular.module('scupr', ['ionic'])

onLoad = () ->
	alert("Device Loading")
	document.addEventListener("deviceready", onDeviceReady, false)
# device APIs are available

onDeviceReady = () ->
        alert("Device Ready")
        getBucket()

getBucket = () ->
	alert("get bucket!")
	$.get("http://localhost:3000/ads", (data) ->
  	fillBucket(data))

fillBucket = (data)->
	alert("fill bucket!")
	console.log(data)
	source   = $("#bucket-template").html()
	console.log(source)
	template = Handlebars.compile(source)
	console.log(template)
	$('#bucket').html(template(data))

Handlebars.registerHelper('createBucket', (ad)->
	console.log(ad)
	new Handlebars.SafeString("""
	<a class='item item-thumbnail-left' href= "#">
    <img src= "http://localhost:3000#{ad.bucket_image}"/>
    <h2>#{ad.business_name}</h2>
    <p>#{ad.caption}</p>
  </a>
  """)
)