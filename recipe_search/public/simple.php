<?php

require __DIR__ . '/../vendor/autoload.php';

use RecipeSearch\Constants;

// Get search results from Elasticsearch if the user searched for something
$results = [];
if (!empty($_REQUEST['submitted'])) {

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
  <title>Recipe Search &mdash; Simple</title>
  <link rel="stylesheet" href="/css/bootstrap.min.css" />
</head>
<body>
<div class="container">
<h1>Recipe Search &mdash; Simple</h1>
<form method="get" action="<?php echo $_SERVER['PHP_SELF']; ?>" class="form-inline">
  <input name="q" value="<?php echo $_REQUEST['q']; ?>" type="text" placeholder="What are you hungry for?" class="form-control input-lg" size="40" />
  <input type="hidden" name="submitted" value="true" />
  <input type="submit" value="Search" class="btn btn-lg" />
  <span>&nbsp;<a href="/advanced.php">Switch to advanced search</a></span>
</form>
<?php

if (isset($_REQUEST['submitted'])) {
  include __DIR__ . "/results.php";
}

?>
</div>
</body>
</html>
