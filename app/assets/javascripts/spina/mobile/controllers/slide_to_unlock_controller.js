(() => {
  const application = Stimulus.Application.start()

  application.register("slide-to-unlock", class extends Stimulus.Controller {
    static get targets() {
      return ["range", "label"]
    }
    
    connect() {
      this.rangeTarget['slideToUnlock'] = this
      this.renderLabel()
    }
    
    renderLabel() {
      let width = this.rangeTarget.offsetWidth
      let left = (width - 10) / 100 * this.rangeTarget.value
      let thumbWidth = 80 / 100 * this.rangeTarget.value
      this.labelTarget.style.left = `${20 + 5 + left - thumbWidth}px`
    }
    
  })
})()