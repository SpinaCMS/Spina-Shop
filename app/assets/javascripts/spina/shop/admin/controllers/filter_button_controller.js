(() => {
  const application = Stimulus.Application.start()

  application.register("filter-button", class extends Stimulus.Controller {
    static get targets() {
      return ["input", "button"]
    }
    
    filter() {
      if (this.filtered) {
        this.buttonTarget.classList.add(...this.cssClasses)
      } else {
        this.buttonTarget.classList.remove(...this.cssClasses)
      }
    }
    
    get cssClasses() {
      return this.element.dataset.filterButtonClasses.split(" ")
    }
    
    get filtered() {
      return this.inputTargets.some((input) => input.checked || input.selected)
    }

  })
})()