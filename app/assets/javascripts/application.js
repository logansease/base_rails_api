// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// Note that the requirement of rails.js is a bug fix for the default rails.js that is included in the
// jquery-ujs package. Which prevents confirmation popups from showing
//= require jquery
//= require jquery-ui
//= require rails
//= require facebook
//= require_tree .

$(function() {
  $('.date_picker').datepicker();
});
