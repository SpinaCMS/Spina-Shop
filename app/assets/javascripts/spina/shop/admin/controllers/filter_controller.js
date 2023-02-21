(() => {
  const application = Stimulus.Application.start()

  application.register("filter", class extends Stimulus.Controller {
    static get targets() {
      return ["form", "submitButton", "records"]
    }
    
    delayedSubmit = debounce(function() {
      this.submitButtonTarget.click()
    }.bind(this), 300)
    
    submit(event) {
      this.recordsTarget.innerHTML = `<div class="table-cell p-4 py-2 text-gray-400 text-sm">Zoeken...</div>`
      this.delayedSubmit()
    }

  })
})()

// Returns a function, that, as long as it continues to be invoked, will not
// be triggered. The function will be called after it stops being called for
// N milliseconds. If `immediate` is passed, trigger the function on the
// leading edge, instead of the trailing.
function debounce(func, wait, immediate) {
  var timeout;
  return function() {
    var context = this, args = arguments;
    var later = function() {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };
    var callNow = immediate && !timeout;
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
    if (callNow) func.apply(context, args);
  };
};