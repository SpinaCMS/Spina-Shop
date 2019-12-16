(() => {
  const application = Stimulus.Application.start()

  application.register("refund", class extends Stimulus.Controller {

    static get targets() {
      return ["deallocateStock", "createRefund", "chooseLines"]
    }

    toggleEntireOrder(event) {
      if (event.currentTarget.checked) {
        this.deallocateStockTarget.style.display = "flex"
        this.createRefundTarget.style.display = "block"
        this.chooseLinesTarget.style.display = "none"
      } else {
        this.deallocateStockTarget.style.display = "none"
        this.createRefundTarget.style.display = "none"
        this.chooseLinesTarget.style.display = "block"
      }
    }

  })
})()