//= require jquery
//= require jquery_ujs

//= require turbolinks

// Stimulus

//= require spina/stimulus.umd
//= require_tree ./controllers

$(document).on("click", "#edit_stock", function() {

  $(this).next().show();
  $(this).remove();

});