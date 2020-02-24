(() => {
  const application = Stimulus.Application.start()

  application.register("customer-select", class extends Stimulus.Controller {

    connect() {
      this.initSelect2()
    }

    initSelect2() {
      $(this.element).select2({
        ajax: {
          url: "/admin/shop/customers",
          delay: 250,
          dataType: 'json',
          data: function(params) {
            return {q: {full_name_or_company_cont: params.term}, page: params.page}
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
        templateResult: function(customer) {
          if (customer.loading) return customer.name
          if (customer.company) {
            return `<div class='select-products-result'><span>${customer.company} <small>${customer.full_name}</small></span></div>` 
          } else {
            return `<div class='select-products-result'><span>${customer.full_name} <small>${customer.id}</small></span></div>`
          }
        },
        templateSelection: function(customer) {
          return customer.text || customer.name
        }
      })
    }

  })
})()