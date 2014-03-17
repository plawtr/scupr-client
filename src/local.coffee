onLoad = () ->
	alert("Device Loading")
	document.addEventListener("deviceready", onDeviceReady, false)
# device APIs are available

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