# Dynamically add and remove fields in a nested form
$(document).on 'click', 'form .add_address_fields', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).before($(this).data('fields').replace(regexp, time))

  # Fire event
  $(this).closest('form').trigger('spina:address_fields_added')

  event.preventDefault()

$(document).on 'click', 'form .remove_address_fields', (event) ->
  $(this).prev('input[type=hidden]').val('1')
  $(this).closest('.sidebar-form-group').slideUp()
  event.preventDefault()

ready = ->
  if $('#validate_vat_id').length
    url = $('#validate_vat_id').attr('data-url')
    $.getJSON url, (response) ->
      if response.valid
        $('#validate_vat_id .result').html('<i class="icon icon-check text-success"></i>')
        $('#validate_vat_id .result').append("<pre>#{response.details.name}#{response.details.address}</pre>")
      else
        $('#validate_vat_id .result').html('<i class="icon icon-cross text-danger"></i>')

$(document).on 'turbo:load', ready