$( "#add-ingredient" ).on("click", function(e) {
  var linkEl = e.target;
  var newEl = $(linkEl.previousElementSibling).clone();
  newEl.insertBefore(linkEl);
});

$( "#add-step" ).on("click", function(e) {
  var linkEl = e.target;
  var newEl = $(linkEl.previousElementSibling).clone();
  newEl.insertBefore(linkEl);
});
