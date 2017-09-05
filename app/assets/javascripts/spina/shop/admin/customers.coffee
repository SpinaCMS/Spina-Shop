ready = ->
  if $('#validate_vat_id').length
    url = $('#validate_vat_id').attr('data-url')
    $.getJSON url, (response) ->
      if response.valid
        $('#validate_vat_id .result').html('<i class="icon icon-check text-success"></i>')
        $('#validate_vat_id .result').append("<pre>#{response.details.name}#{response.details.address}</pre>")
      else
        $('#validate_vat_id .result').html('<i class="icon icon-cross text-danger"></i>')

$(document).on 'turbolinks:load', ready