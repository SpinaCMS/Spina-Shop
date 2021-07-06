(() => {
  const application = Stimulus.Application.start()

  application.register("location-code-select", class extends Stimulus.Controller {

    connect() {
      this.initSelect2()
    }

    initSelect2() {
      let location_id = this.element.dataset.locationId
      
      $(this.element).select2({
        ajax: {
          url: `/admin/shop/locations/${location_id}/location_codes`,
          delay: 250,
          dataType: 'json',
          data: function(params) {
            return {q: {code_cont: params.term}, page: params.page}
          },
          processResults: function(data, params) {
            params.page = params.page || 1
            return {
              results: data.results,
              pagination: { 
                more: (params.page * 25) < data.total_count 
              }
            }
          }
        },
        escapeMarkup: function(markup) {
          return markup
        },
        templateResult: function(location_code) {
          if (location_code.loading) return location_code.code
          return `<div class='select-products-result'><span>${location_code.code} <small class='pull-right'>${location_code.product_count} product(en)</small></span></div>`
        },
        templateSelection: function(location_code) {
          return location_code.text || location_code.code
        }
      })
    }

  })
})()