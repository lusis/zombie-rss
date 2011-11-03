$(document).ready(function() {
  $(".span8").delegate("a", "click", function() {
      var feed_id = $(this).attr('data-feed_id');
      $.post('/feed/'+feed_id, function(data) {
        $("#feed-display-area").replaceWith(data);
      });
    });
});

$(function() {
  $("a[rel=popover]").popover({offset: -10}).click(function(e) {
      e.preventDefault()
    })
});
