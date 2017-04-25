# Dynamically add and remove fields in a nested form
$(document).on 'click', 'form .add_product_item_fields', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).before($(this).data('fields').replace(regexp, time))

  # Fire event
  $(this).closest('form').trigger('spina:product_item_fields_added')

  event.preventDefault()

$(document).on 'click', 'form .remove_fields', (event) ->
  $(this).prev('input[type=hidden]').val('1')
  $(this).closest('.sidebar-form-group').slideUp()
  event.preventDefault()