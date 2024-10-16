// Stop rails-ujs from submitting forms and let normal html form submission take over
document.querySelectorAll('form').forEach(function (form) {
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    form.submit();
  });
});
document.addEventListener('turbo:load', function () {
  document.querySelectorAll('form').forEach(function (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      form.submit();
    });
  });
});
