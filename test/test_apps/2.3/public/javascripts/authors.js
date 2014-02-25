document.observe("dom:loaded", function() {
  $$('.js-delay-show').each(function(element) {
    Event.observe(element, 'click', function(event) {
      setTimeout(function() {
        window.location.href = event.target.getAttribute("data-href");
      }, 3000);
    });
  });
});
