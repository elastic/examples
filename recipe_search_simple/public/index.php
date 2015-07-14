<?php

require __DIR__ . '/../vendor/autoload.php';

use RecipeSearchSimple\Constants;

// Get search results from Elasticsearch if the user searched for something
$results = [];
if (!empty($_REQUEST['q'])) {

    // Connect to Elasticsearch (1-node cluster)
    $esPort = getenv('APP_ES_PORT') ?: 9200;
    $client = new Elasticsearch\Client([
        'hosts' => [ 'localhost:' . $esPort ]
    ]);

    // Setup search query
    $searchParams['index'] = Constants::ES_INDEX; // which index to search
    $searchParams['type']  = Constants::ES_TYPE;  // which type within the index to search
    $searchParams['body']['query']['match']['_all'] = $_REQUEST['q']; // what to search for

    // Send search query to Elasticsearch and get results
    $queryResponse = $client->search($searchParams);
    $results = $queryResponse['hits']['hits'];
}
?>
<html>
<head>
  <title>Recipe Search</title>
  <link rel="stylesheet" href="/css/bootstrap.min.css" />
</head>
<body>
<div class="container">
<h1>Recipe Search</h1>
<form method="get" action="<?php echo $_SERVER['PHP_SELF']; ?>" class="form-inline">
  <input name="q" value="<?php echo $_REQUEST['q']; ?>" type="text" placeholder="What are you hungry for?" class="form-control input-lg" size="40" />
  <input type="submit" value="Search" class="btn btn-lg" />
</form>
<?php
if (count($results) > 0) {
?>
<table class="table table-striped">
<thead>
  <th>Name</th>
  <th>Description</th>
  <th>Cooking time (minutes)</th>
</thead>
<?php
    foreach ($results as $result) {
        $recipe = $result['_source'];
?>
<tr>
  <td><a href="/view.php?id=<?php echo $result['_id']; ?>"><?php echo $recipe['name']; ?></a></td>
  <td><?php echo $recipe['description']; ?></td>
  <td><?php echo $recipe['cooking_time_min']; ?></td>
</tr>
<?php
    } // END foreach loop over results
?>
</table>
<?php
} // END if there are search results

elseif (!empty($_REQUEST['q'])) {
?>
<p>Sorry, no recipes with <em><?php echo $_REQUEST['q']; ?></em> found :( Would you like to <a href="/add.php">add</a> one?</p>
<?php

} // END elsif there are no search results

?>
</div>
</body>
</html>
