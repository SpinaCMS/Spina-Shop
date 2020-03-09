//= require jquery
//= require jquery_ujs
//= require turbolinks

$(document).on("click", "#edit_stock", function() {

  $(this).next().show();
  $(this).remove();

});