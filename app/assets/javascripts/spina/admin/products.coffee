ready = ->
  el = document.getElementById('productImageUploader')
  if el
    sortable = Sortable.create el, {
      onSort: (e) ->
        for id, index in sortable.toArray()
          $(el).find(".sidebar-form-image[data-id='#{id}'] .product-image-position").val(index)
    }

  $('select.select2').select2({tags: true})
  $('select.select-products').each ->
    $select = $(this)
    selected = $select.attr('data-value')
    label = $select.attr('data-label')
    $select.select2(
      ajax:
        url: '/admin/products'
        delay: 250
        dataType: 'json'
        data: (params) ->
          q: {product_items_sku_or_name_cont: params.term}, page: params.page
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
    $option = $("<option selected>#{label}</option>").val(selected);
    $select.append($option).trigger('change')

  $('.infinite-table .pagination, .infinite-list .pagination').infiniteScroll()

$(document).on 'turbolinks:load', ready

$(document).on 'click', '.sidebar-form-image a', (e) ->
  $checkbox = $(this).parents('.sidebar-form-image').find('input[type="checkbox"]')
  $checkbox.prop("checked", !$checkbox.prop("checked"))
  e.preventDefault()
