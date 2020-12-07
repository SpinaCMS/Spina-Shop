(() => {
  const application = Stimulus.Application.start()

  application.register("order-picking", class extends Stimulus.Controller {
    static get targets() {
      return ["orderItem", "range", "quantity"]
    }
    
    connect() {
      this.hideAll()
      this.show(this.index)
    }
    
    unlock(event) {
      let range = event.currentTarget
      let value = range.value
      if (value == 100) {
        this.element.dataset.index = this.index + 1
        this.hideAll()
        this.show(this.index)
      } else {
        this.slideToUnlock = setInterval(function() {
          if (value != 0) range.value = value--
          range.slideToUnlock.renderLabel()
        }, 1)
      }
    }
    
    clearInterval(event) {
      clearInterval(this.slideToUnlock)
    }
    
    show(index) {
      let orderItem = this.orderItemTargets.find(function(order_item) {
        return order_item.dataset.index == index
      })
      orderItem.style.display = 'block'
    }
    
    hideAll() {
      this.orderItemTargets.forEach(function(order_item) {
        order_item.style.display = 'none'
      })
    }
    
    get index() {
      return parseInt(this.element.dataset.index)
    }
    
  })
})()