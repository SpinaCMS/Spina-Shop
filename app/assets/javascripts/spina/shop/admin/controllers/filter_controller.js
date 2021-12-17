(() => {
  const application = Stimulus.Application.start()

  application.register("filter", class extends Stimulus.Controller {
    static get targets() {
      return ["form", "submitButton"]
    }
    
    submit(event) {
      this.submitButtonTarget.click()
    }

  })
})()