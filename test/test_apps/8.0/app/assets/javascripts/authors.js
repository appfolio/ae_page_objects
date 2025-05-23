// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$(function() {
  $('.js-delay-show').on('click', function(event) {
    setTimeout(function() {
      window.location.href = event.target.getAttribute("data-href");
    }, 3000);
  })
})

