window.Spina = {}

class Spina.Products
  @enhance: (element) ->
    element.find('select.select-products:not(.select2-hidden-accessible)').each ->
      $select = $(this)
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
            q: {translations_name_start: params.term}, page: params.page
          minimumInputLength: 1
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
          "<div class='select-products-result'><div class='select-products-result-image'><img src='#{product.image_url}' /></div><span>#{product.name} <small>#{product.price} - voorraad: #{product.stock_level}</small></span></div>"
        templateSelection: (product) ->
          if product.name
            product.name + " (#{product.stock_level})"
          else
            product.text 
        minimumInputLength: 1
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
  $('select.select2').select2()
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
  $(this).before($(this).data('fields').replace(regexp, time))

  # Fire event
  $(this).closest('form').trigger('spina:price_exception_added')

  event.preventDefault()

$(document).on 'click', 'form .remove_price_exception', (event) ->
  $(this).closest('.form-control').slideUp 400, ->
    $(this).remove()
  event.preventDefault()
