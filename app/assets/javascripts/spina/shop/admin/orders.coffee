toggleSwitch = (toggle) ->
  $toggle = toggle
  $target = $($toggle.attr('data-toggle'))

  if $toggle.prop('checked')
    $target.show()
  else
    $target.hide()

ready = ->
  $('[data-toggle]').each ->
    toggleSwitch($(this))

$(document).on 'change', '[data-toggle]', (e) ->
  console.log 'hoi'
  toggleSwitch($(this))

$(document).on 'turbolinks:load', ready