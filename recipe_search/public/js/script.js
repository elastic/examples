var addBlankItemToList = function(e) {
  var linkEl = e.target;
  var newEl = $(linkEl.previousElementSibling).clone();
  newEl.children(0).children(0).children(0).val("");
  newEl.insertBefore(linkEl);
}

$( "#add-ingredient" ).on("click", addBlankItemToList);
$( "#add-step" ).on("click", addBlankItemToList);
