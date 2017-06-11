ready = ->
  el = document.getElementById('productImageUploader')
  if el
    sortable = Sortable.create el, {
      onSort: (e) ->
        for id, index in sortable.toArray()
          $(el).find(".sidebar-form-image[data-id='#{id}'] .product-image-position").val(index)
    }

  selectProductItems($(this))

  $('select.select2').select2()
  $('.infinite-table .pagination, .infinite-list .pagination').infiniteScroll()

  selectProducts($(document))

$(document).on 'turbolinks:load', ready

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
  selectProducts($(this))

$(document).on 'spina:product_item_fields_added', 'form', (e) ->
  selectProductItems($(this))
  $('select.select2').select2()

selectProducts = (element) ->
  element.find('select.select-products').each ->
    $select = $(this)
    $select.select2(
      ajax:
        url: '/admin/products'
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
        "<div class='select-products-result'><div class='select-products-result-image'><img src='#{product.image_url}' /></div><span>#{product.name} <small>#{product.price}</small></span></div>"
      templateSelection: (product) ->
        product.name || product.text
      minimumInputLength: 1
    )

selectProductItems = (element) ->
  element.find('select.select-product-items').each ->
    $select = $(this)
    $select.select2(
      ajax:
        url: '/admin/shop/product_items'
        delay: 250
        dataType: 'json'
        data: (params) ->
          q: {product_translations_name_start: params.term}, page: params.page
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
        "<div class='select-products-result'><div class='select-products-result-image'><img src='#{product.image_url}' /></div><span>#{product.name} <small>#{product.price}</small></span></div>"
      templateSelection: (product) ->
        product.name || product.text
      minimumInputLength: 1
    )
