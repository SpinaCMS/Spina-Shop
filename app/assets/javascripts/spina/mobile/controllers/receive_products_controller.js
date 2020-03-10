(() => {
  const application = Stimulus.Application.start()

  application.register("receive-products", class extends Stimulus.Controller {
    static get targets() {
      return ["receivedField"]
    }

    connect() {
      this.validateReceivedField()
    }

    validateReceivedField() {
      if (this.receivedInput == this.shouldInput) {
        this.receivedFieldTarget.classList.remove("warning")
        this.receivedFieldTarget.classList.add("success")
      } else {
        this.receivedFieldTarget.classList.remove("success")
        this.receivedFieldTarget.classList.add("warning")
      }
    }

    get shouldInput() {
      return parseInt(this.element.dataset.shouldReceive)
    }

    get receivedInput() {
      return parseInt(this.receivedFieldTarget.value)
    }

  })
})()