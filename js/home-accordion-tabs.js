//
// home page tab navigation
//

$(document).ready(function () {
  $('.accordion-tabs').each(function(index) {
    // add is-active class to first element and is-open all others 
    $(this).children('li').first().children('a').addClass('is-active').next().addClass('is-open').show();
  });
  $('.accordion-tabs').on('click', 'li > a.tab-link', function(e) {
    // if clicked tab is not active, remove existing active class and give to this one 
    if (!$(this).hasClass('is-active')) {
      e.preventDefault();
      var accordionTabs = $(this).closest('.accordion-tabs'); 
      accordionTabs.find('.is-open').removeClass('is-open').hide();

      $(this).next().toggleClass('is-open').toggle(); 
      accordionTabs.find('.is-active').removeClass('is-active');
      $(this).addClass('is-active');
    } else {
      e.preventDefault();
    }
  });
});

