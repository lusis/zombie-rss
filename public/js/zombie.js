$(document).ready(function() {
  $("[id^='z-feed-']").delegate("span", "click", function() {
    var feed_id = $(this).attr('id');
    $("#feed-title").replaceWith(
    "<h1 id='feed-title'>Feed " + feed_id + "</h1>"
    );
  });
});
