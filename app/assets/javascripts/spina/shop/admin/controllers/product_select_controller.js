(() => {
  const application = Stimulus.Application.start()

  application.register("product-select", class extends Stimulus.Controller {
    
    connect() {
      Spina.Products.enhance($(this.element))
    }

  })
})()