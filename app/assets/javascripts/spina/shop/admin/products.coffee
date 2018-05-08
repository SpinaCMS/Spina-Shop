window.Spina = {}

class Spina.Products
  @enhance: (element) ->
    element.find('select.select-products:not(.select2-hidden-accessible)').each ->
      $select = $(this)
      scope = $select.attr('data-products-scope')
      if $(this).hasClass('select-product-bundles')
        url = '/admin/shop/product_bundles'
      else
        url = '/admin/shop/products'
      $select.select2(
        ajax:
          url: url
          delay: 250
          dataType: 'json'
          data: (params) ->
            q: {sku_or_location_or_translations_name_cont_all: params.term}, page: params.page, scope: scope
          processResults: (data, params) ->
            params.page = params.page or 1
            return {
              results: data.results
              pagination: { more: (params.page * 25) < data.total_count }
            }
          cache: true
        escapeMarkup: (markup) ->
          return markup
        templateResult: (product) ->
          return product.text if product.loading
          "<div class='select-products-result'><div class='select-products-result-image'><img style='max-width: 30px; max-height: 30px' src='#{product.image_url}' /></div><span>#{product.name} <small>#{product.price} - voorraad: #{product.stock_level}</small></span></div>"
        templateSelection: (product) ->
          if product.name
            product.name + " – #{product.price} (voorraad: #{product.stock_level})"
          else
            product.text 
      )

$.fn.enhanceProducts = ->
  Spina.Products.enhance(this)

ready = ->
  el = document.getElementById('productImageUploader')
  if el
    sortable = Sortable.create el, {
      onSort: (e) ->
        for id, index in sortable.toArray()
          $(el).find(".sidebar-form-image[data-id='#{id}'] .product-image-position").val(index)
    }

  $('body').enhanceProducts()
  $('select.select2').each ->
    $select = $(this)
    $select.select2({placeholder: $select.attr('placeholder')})
  $('.infinite-table .pagination, .infinite-list .pagination').infiniteScroll()

$(document).on 'turbolinks:load', ready

$(document).on 'turbolinks:before-cache', ->
  $('select.select2').select2('destroy')
  $('select.select-products').select2('destroy')

$(document).on 'click', '.filter-form-advanced-link', (e) ->
  $('.filter-form-advanced').animate({
    margin: 'toggle',
    height: 'toggle',
    opacity: 'toggle'
  })
  e.preventDefault()

$(document).on 'click', '.sidebar-form-image a', (e) ->
  $checkbox = $(this).parents('.sidebar-form-image').find('input[type="checkbox"]')
  $checkbox.prop("checked", !$checkbox.prop("checked"))
  e.preventDefault()

$(document).on 'spina:structure_added', 'form', (e) ->
  $(this).enhanceProducts()

$(document).on 'spina:product_fields_added', 'form', (e) ->
  $(this).enhanceProducts()
  $('select.select2').select2()

# Dynamically add and remove fields in a nested form
$(document).on 'click', 'form .add_price_exception', (event) ->
  time = new Date().getTime()
  regexp = new RegExp($(this).data('id'), 'g')
  $(this).parents().find('.price-exceptions').append($(this).data('fields').replace(regexp, time))

  # Fire event
  $(this).closest('form').trigger('spina:price_exception_added')

  event.preventDefault()

$(document).on 'click', 'form .remove_price_exception', (event) ->
  $(this).closest('.form-control').slideUp 400, ->
    $(this).remove()
  event.preventDefault()

$(document).on 'checked', 'table.products-table thead .form-checkbox input', (event) ->
  if $(this).prop('checked')
    $(this).closest('table').find('tbody tr td .form-checkbox input[type="checkbox"]').prop('checked', true)
    count = $(this).attr('data-count')
    if count > 0
      $('.products-batch-action span.selected').text("(#{count})")
    else
      $('.products-batch-action span.selected').text("")
  else
    $(this).closest('table').find('tbody tr td .form-checkbox input[type="checkbox"]').prop('checked', false)
    $('.products-batch-action span.selected').text("")

$(document).on 'checked', 'table.products-table tbody .form-checkbox input', (event) ->
  $('table.products-table thead .form-checkbox input').prop('checked', false)
  
  count = $('table.products-table tbody .form-checkbox input:checked').length
  if count > 0
    $('.products-batch-action span.selected').text("(#{count})")
  else
    $('.products-batch-action span.selected').text("")

$(document).on 'change', '.form-checkbox input[type="checkbox"][data-disabled-toggle]', (e) ->
  checked = $(this).prop('checked')
  console.log(checked)

  $target = $($(this).attr('data-disabled-toggle'))

  if checked
    $target.find('.select-dropdown').removeAttr('data-disabled')
    $target.find('.select-dropdown select, input[type="text"]').removeAttr('disabled')
    $target.find('.add-pricing-dropdown').show()
    if $target.hasClass('disabled-toggle-stores')
      $target.show()
  else
    $target.find('.select-dropdown').attr('data-disabled', true)
    $target.find('.select-dropdown select, input[type="text"]').attr('disabled', 'disabled')
    $target.find('.add-pricing-dropdown').hide()
    if $target.hasClass('disabled-toggle-stores')
      $target.hide()

$(document).on 'change', '#translations_modal_select select', (e) ->
  $('.modal .tab-content').removeClass('active')
  $(".modal .tab-content#translations_#{$(this).val()}").addClass('active')