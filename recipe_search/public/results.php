<?php
if (count($results) > 0) {
?>
<table class="table table-striped">
<thead>
  <th>Title</th>
  <th>Description</th>
	<th>Preparation time (minutes)</th>
  <th>Cooking time (minutes)</th>
</thead>
<?php
    foreach ($results as $result) {
        $recipe = $result['_source'];
?>
<tr>
  <td><a href="/view.php?id=<?php echo $result['_id']; ?>"><?php echo $recipe['title']; ?></a></td>
  <td><?php echo $recipe['description']; ?></td>
	<td><?php echo $recipe['prep_time_min']; ?></td>
  <td><?php echo $recipe['cook_time_min']; ?></td>
</tr>
<?php
    } // END foreach loop over results
?>
</table>
<?php
} // END if there are search results

else {
?>
<p>Sorry, no recipes found :( Would you like to <a href="/add.php">add</a> one?</p>
<?php

} // END elsif there are no search results

?>
