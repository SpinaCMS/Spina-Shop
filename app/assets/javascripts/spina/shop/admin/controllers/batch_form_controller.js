(() => {
  const application = Stimulus.Application.start()

  application.register("batch-form", class extends Stimulus.Controller {

    submit(event) {
      let button = event.currentTarget
      this.element.action = button.dataset.url
    }

  })
})()