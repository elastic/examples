<?php

require __DIR__ . '/../vendor/autoload.php';

use RecipeSearch\Constants;
use Elasticsearch\Common\Exceptions\Missing404Exception;
use Elasticsearch\ClientBuilder;

error_reporting(E_ALL ^ E_NOTICE);

$message = $_REQUEST['message'];

// Check if recipe ID was provided
if (empty($_REQUEST['id'])) {
    $message = 'No recipe requested! Please provide a recipe ID.';
} else {
   // Connect to local Elasticsearch node
    $esPort = getenv('APP_ES_PORT') ?: 9200;
    $hosts = [
        'localhost:' . $esPort
    ];
    $client = ClientBuilder::create()           // Instantiate a new ClientBuilder
                        ->setHosts($hosts)      // Set the hosts
                        ->build();              // Build the client object

    // Try to get recipe from Elasticsearch
    try {
        $recipe = $client->get([
            'id'    => $_REQUEST['id'],
            'index' => Constants::ES_INDEX,
            'type'  => Constants::ES_TYPE
        ]);
        $recipe = $recipe['_source'];
    } catch (Missing404Exception $e) {
        $message = 'Requested recipe not found :(';
    }
}
?>
<html>
<head>
  <title>Recipe Search</title>
  <link rel="stylesheet" href="/css/bootstrap.min.css" />
</head>
<body>
<div class="container bg-danger" id="message">
<?php
if (!empty($message)) {
?>
<h1><?php echo $message; ?></h1>
<?php
}
?>
</div>

<div class="container">
<h1><?php echo $recipe['title']; ?></h1>
<p><em><?php echo $recipe['description']; ?></em></p>
</div>

<?php
if (!empty($recipe['prep_time_min'])) {
?>
<div class="container">
  <p>Preparation time: <?php echo $recipe['prep_time_min']; ?> minutes</p>
</div>
<?php
}
?>

<?php
if (!empty($recipe['cook_time_min'])) {
?>
<div class="container">
  <p>Cooking time: <?php echo $recipe['cook_time_min']; ?> minutes</p>
</div>
<?php
}
?>

<!-- Ingredients -->
<div class="container">
<h3>Ingredients</h3>
<ul>
<?php
foreach ($recipe['ingredients'] as $ingredient) {
?>
  <li><?php echo $ingredient; ?></li>
<?php
}
?>
</ul>
</div>

<!-- Directions -->
<div class="container">
<h3>Directions</h3>
<ol>
<?php
foreach ($recipe['directions'] as $step) {
?>
  <li><?php echo $step; ?></li>
<?php
}
?>
</ol>
</div>

<?php
if (!empty($recipe['servings'])) {
?>
<div class="container">
  <p><em>Serves <?php echo $recipe['servings']; ?>.</em></p>
</div>
<?php
}
?>

</body>
</html>
