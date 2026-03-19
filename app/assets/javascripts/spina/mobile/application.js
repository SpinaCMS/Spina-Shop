//= require jquery
//= require rails-ujs

//= require spina/turbo.es2017-umd

// Stimulus

//= require spina/stimulus.umd
//= require_tree ./controllers

$(document).on("click", "#edit_stock", function() {

  $(this).next().show();
  $(this).remove();

});