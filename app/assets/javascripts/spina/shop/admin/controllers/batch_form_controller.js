(() => {
  const application = Stimulus.Application.start()

  application.register("batch-form", class extends Stimulus.Controller {

    connect() {
      
    }

    submit(event) {
      event.preventDefault()
      let button = event.currentTarget
      this.element.action = button.dataset.url
      $(this.element).trigger("submit.rails")
    }

  })
})()