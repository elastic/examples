<?php

require __DIR__ . '/../vendor/autoload.php';

use RecipeSearch\Constants;
use RecipeSearch\Util;
use Elasticsearch\ClientBuilder;

// Get search results from Elasticsearch if the user searched for something
$results = [];
error_reporting(E_ALL ^ E_NOTICE);

if (!empty($_REQUEST['submitted'])) {

    // Connect to local Elasticsearch node
    $esPort = getenv('APP_ES_PORT') ?: 9200;
    $hosts = [
        'localhost:' . $esPort
    ];
    $client = ClientBuilder::create()           // Instantiate a new ClientBuilder
                        ->setHosts($hosts)      // Set the hosts
                        ->build();              // Build the client object

    // Setup search query
    $searchParams['index'] = Constants::ES_INDEX; // which index to search
    $searchParams['type']  = Constants::ES_TYPE;  // which type within the index to search
    $searchParams['body'] = [];

    // First, setup full text search bits
    $fullTextClauses = [];
    if ($_REQUEST['title']) {
      $fullTextClauses[] = [ 'match' => [ 'title' => $_REQUEST['title'] ] ];
    }

    if ($_REQUEST['description']) {
      $fullTextClauses[] = [ 'match' => [ 'description' => $_REQUEST['description'] ] ];
    }

    if ($_REQUEST['ingredients']) {
      $fullTextClauses[] = [ 'match' => [ 'ingredients' => $_REQUEST['ingredients'] ] ];
    }

    if ($_REQUEST['directions']) {
      $fullTextClauses[] = [ 'match' => [ 'directions' => $_REQUEST['directions'] ] ];
    }

    if ($_REQUEST['tags']) {
      $tags = Util::recipeTagsToArray($_REQUEST['tags']);
      $fullTextClauses[] = [ 'terms' => [
        'tags' => $tags,
        'minimum_should_match' => count($tags)
      ] ];
    }

    if (count($fullTextClauses) > 0) {
      $query = [ 'bool' => [ 'must' => $fullTextClauses ] ];
    } else {
      $query = [ 'match_all' => (object) [] ];
    }

    // Then setup exact match bits
    $filterClauses = [];

    if ($_REQUEST['prep_time_min_low'] || $_REQUEST['prep_time_min_high']) {
      $rangeFilter = [];
      if ($_REQUEST['prep_time_min_low']) {
        $rangeFilter['gte'] = (int) $_REQUEST['prep_time_min_low'];
      }
      if ($_REQUEST['prep_time_min_high']) {
        $rangeFilter['lte'] = (int) $_REQUEST['prep_time_min_high'];
      }
      $filterClauses[] = [ 'range' => [ 'prep_time_min' => $rangeFilter ] ];
    }

    if ($_REQUEST['cook_time_min_low'] || $_REQUEST['cook_time_min_high']) {
      $rangeFilter = [];
      if ($_REQUEST['cook_time_min_low']) {
        $rangeFilter['gte'] = (int) $_REQUEST['cook_time_min_low'];
      }
      if ($_REQUEST['cook_time_min_high']) {
        $rangeFilter['lte'] = (int) $_REQUEST['cook_time_min_high'];
      }
      $filterClauses[] = [ 'range' => [ 'cook_time_min' => $rangeFilter ] ];
    }

    if ($_REQUEST['servings']) {
      $filterClauses[] = [ 'term' => [ 'servings' => $_REQUEST['servings'] ] ];
    }

    if (count($filterClauses) > 0) {
      $filter = [ 'bool' => [ 'must' => $filterClauses ] ];
    }

    // Build complete search request body
    if (count($filterClauses) > 0) {
      $searchParams['body'] = [ 'query' =>
        [ 'filtered' =>
          [ 'query' => $query, 'filter' => $filter ]
        ]
      ];
    } else {
      $searchParams['body'] = [ 'query' => $query ];
    }

    // Send search query to Elasticsearch and get results
    $queryResponse = $client->search($searchParams);
    $results = $queryResponse['hits']['hits'];
}
?>
<html>
<head>
  <title>Recipe Search &mdash; Advanced</title>
  <link rel="stylesheet" href="/css/bootstrap.min.css" />
</head>
<body>
<div class="container">
<h1>Recipe Search &mdash; Advanced</h1>
<form method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">

  <!-- Basic information about the recipe -->
  <div class="container">
    <div class="form-group">
      <div class="row">
        <div class="col-xs-5">
          <label for="title">Title contains...</label>
          <input name="title" value="<?php echo $_REQUEST['title']; ?>" class="form-control" />
        </div>
        <div class="col-xs-2">
          <label for="prep_time_min_low">Preparation time is between...</label>
          <input name="prep_time_min_low" value="<?php echo $_REQUEST['prep_time_min_low']; ?>" type="number" placeholder="minutes" class="form-control"/>
          <label for="prep_time_min_high">and</label>
          <input name="prep_time_min_high" value="<?php echo $_REQUEST['prep_time_min_high']; ?>" type="number" placeholder="minutes" class="form-control"/>
        </div>
        <div class="col-xs-2">
          <label for="cook_time_min_low">Cooking time is between...</label>
          <input name="cook_time_min_low" value="<?php echo $_REQUEST['cook_time_min_low']; ?>" type="number" placeholder="minutes" class="form-control"/>
          <label for="cook_time_min_high">and</label>
          <input name="cook_time_min_high" value="<?php echo $_REQUEST['cook_time_min_high']; ?>" type="number" placeholder="minutes" class="form-control"/>
        </div>
        <div class="col-xs-1">
          <label for="servings">Servings</label>
          <input name="servings" value="<?php echo $_REQUEST['servings']; ?>" type="number" class="form-control"/>
        </div>
      </div>
    </div>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-10">
          <label for="description">Description contains...  </label>
          <input name="description" value="<?php echo $_REQUEST['description']; ?>" class="form-control"/>
        </div>
      </div>
    </div>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-5">
          <label for="ingredients">Ingredients contain...  </label>
          <input name="ingredients" value="<?php echo $_REQUEST['ingredients']; ?>" class="form-control"/>
        </div>
        <div class="col-xs-5">
          <label for="directions">Directions contain...  </label>
          <input name="directions" value="<?php echo $_REQUEST['directions']; ?>" class="form-control"/>
        </div>
      </div>
    </div>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-10">
          <label for="tags">Tags contain...</label>
          <input name="tags" value="<?php echo $_REQUEST['tags']; ?>" placeholder="Comma-separated" class="form-control"/>
        </div>
      </div>
    </div>
  <div class="form-group">
    <div class="row">
      <div class="col-xs-10">
        <label for="tags">Show request JSON?</label>
        <input type="checkbox" name="debug" value="true"<?php echo ($_REQUEST['debug'] ? " checked" : ""); ?> />
      </div>
    </div>
  </div>
  </div>

  <input type="hidden" name="submitted" value="true" />
  <input type="submit" value="Search" class="btn btn-default" />
  <span>&nbsp;<a href="/simple.php">Switch to simple search</a></span>
</form>
<?php

if (isset($_REQUEST['submitted'])) {
  include __DIR__ . "/results.php";

  // Print out request JSON if debug flag is set
  if ($_REQUEST['debug']) {
?>
<h3>Request JSON</h3>
<pre>
<?php echo json_encode($searchParams['body'], JSON_PRETTY_PRINT); ?>
</pre>
<?php
  }
}

?>
</div>
</body>
</html>
