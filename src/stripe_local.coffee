Stripe.setPublishableKey('pk_test_lJZQxPeri5h1HdFfsQFAmF6A')

stripeResponseHandler = (status, response)->
  $form = $('#stripe-form')
  if (response.error) 
    # Show the errors on the form
    $form.find('.payment-errors').text(response.error.message)
    $form.find('button').prop('disabled', false)
  else 
    # token contains id, last4, and card type
    token = response.id
    # Insert the token into the form so it gets submitted to the server
    $form.append($('<input type="hidden" name="stripeToken" />').val(token))
    # and re-submit
    cookie = JSON.parse(window.localStorage.getItem("business"))
    $form.append($('<input type="hidden" name="business-id" />').val(cookie.business.id))
    # $form.get(0).submit()
    data = $form.serializeArray()
    $.post("http:localhost:3000/payment", data, onStripeSuccess)


handleStripe = ()->
  event.preventDefault()

  console.log("one")
  $form = $('#stripe-form')

  # Disable the submit button to prevent repeated clicks
  $form.find('button').prop('disabled', true)

  Stripe.card.createToken($form, stripeResponseHandler)

  # Prevent the form from submitting with the default action
  false

onStripeSuccess = (data)->
  console.log(JSON.stringify(data))
  window.localStorage.setItem("business", JSON.stringify(data))