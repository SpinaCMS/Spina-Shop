(() => {
  const application = Stimulus.Application.start()

  application.register("stock-order", class extends Stimulus.Controller {
    static get targets() {
      return [ "orderedStock" ]
    }

    filter(e) {
      let search = e.currentTarget.value.toLowerCase()
      this.orderedStockTargets.forEach(function(orderedStock) {
        if (orderedStock.dataset.name.toLowerCase().includes(search)) {
          orderedStock.style.display = "flex"
        } else {
          orderedStock.style.display = "none"
        }
      })
    }

  })
})()