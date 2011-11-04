$(document).ready(function() {
  $(".span8").delegate("a", "click", function() {
      var feed_id = $(this).attr('data-feed_id');
      $.post('/feed/'+feed_id, function(data) {
        $("#feed-display-area").replaceWith(data);
      });
    });

  $(".alert-message").alert();

  $("#add_feed_form").delegate("a", "click", function(e) {
      e.preventDefault();
      var feed_url = encodeURIComponent($("#add_feed_input").val());
      $.post('/feed/add/'+feed_url, function(data) {
	var response = $(data)
        $("#z-alert-bar").replaceWith(response);
	window.location = '/';
      });
  });
});

//$(function() {
//  $("a[rel=popover]").popover({offset: 10, placement: 'below'}).click(function(e) {
//      e.preventDefault()
//    })
//});
