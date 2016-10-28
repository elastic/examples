<?php

require __DIR__ . '/../vendor/autoload.php';

use RecipeSearch\Constants;
use RecipeSearch\Util;
use Elasticsearch\ClientBuilder;

error_reporting(E_ALL ^ E_NOTICE);
// Add recipe if one was submitted
if (count($_POST) > 0) {

    $esPort = getenv('APP_ES_PORT') ?: 9200;
    $hosts = [
        'localhost:' . $esPort
    ];
    $client = ClientBuilder::create()           // Instantiate a new ClientBuilder
                        ->setHosts($hosts)      // Set the hosts
                        ->build();              // Build the client object

    // Convert recipe title to ID
    $id = Util::recipeTitleToId($_POST['title']);

    // Check if recipe with this ID already exists
    $exists = $client->exists([
        'id'    => $id,
        'index' => Constants::ES_INDEX,
        'type'  => Constants::ES_TYPE
    ]);

    if ($exists) {
        $message = 'A recipe with this title already exists. You can view it '
            . '<a href="/view.php?id=' . $id . '">here</a> or rename your recipe.';
    } else {
        // Index the recipe in Elasticsearch
        $recipe = $_POST;
        $recipe['tags'] = Util::recipeTagsToArray($_POST['tags']);
        $document = [
            'id'    => $id,
            'index' => Constants::ES_INDEX,
            'type'  => Constants::ES_TYPE,
            'body'  => $recipe
        ];
        $client->index($document);

        // Redirect user to recipe view page
        $message = 'Recipe added!';
        header('Location: /view.php?id=' . $id . '&message=' . $message);
        exit();
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
<p><?php echo $message; ?></p>
<?php
}
?>
</div>
<div class="container">
<h1>Add Recipe</h1>
<form method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">

  <!-- Basic information about the recipe -->
  <div class="container">
    <h3>The Basics</h3>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-5">
          <label for="title">Title</label>
          <input name="title" value="<?php echo $_REQUEST['title']; ?>" required="true" class="form-control" />
        </div>
        <div class="col-xs-2">
          <label for="prep_time_min">Preparation time</label>
          <input name="prep_time_min" value="<?php echo $_REQUEST['prep_time_min']; ?>" type="number" placeholder="minutes" class="form-control"/>
        </div>
        <div class="col-xs-2">
          <label for="cook_time_min">Cooking time</label>
          <input name="cook_time_min" value="<?php echo $_REQUEST['cook_time_min']; ?>" type="number" placeholder="minutes" class="form-control"/>
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
          <label for="description">Description</label>
          <input name="description" value="<?php echo $_REQUEST['description']; ?>" required="true" class="form-control"/>
        </div>
      </div>
    </div>
  </div>

  <!-- Ingredients -->
  <div class="container">
    <h3>Ingredients</h3>
<?php
if (isset($_REQUEST['ingredients']) && (count($_REQUEST['ingredients']) > 0)) {
    foreach ($_REQUEST['ingredients'] as $index => $ingredient) {
?>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-6">
          <input name="ingredients[<?php echo $index; ?>]" value="<?php echo $ingredient; ?>" required="true" class="form-control"/>
        </div>
      </div>
    </div>
<?php
    } // END foreach ingredients
} else {
?>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-6">
          <input name="ingredients[]" required="true" class="form-control"/>
        </div>
      </div>
    </div>
<?php
}
?>
    <a id="add-ingredient" name="add-ingredient" href="#add-ingredient">Add another ingredient</a>
  </div>

  <!-- Directions -->
  <div class="container">
    <h3>Directions</h3>
<?php
if (isset($_REQUEST['directions']) && (count($_REQUEST['directions']) > 0)) {
    foreach ($_REQUEST['directions'] as $index => $step) {
?>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-6">
            <input name="directions[<?php echo $index; ?>]" value="<?php echo $step; ?>" required="true" class="form-control"/>
        </div>
      </div>
    </div>
<?php
    } // END foreach directions
} else {
?>
    <div class="form-group">
      <div class="row">
        <div class="col-xs-6">
          <input name="directions[]" required="true" class="form-control"/>
        </div>
      </div>
    </div>
<?php
}
?>
    <a id="add-step" href="#add-step">Add another step</a>
  </div>

  <div class="container">
    <div class="form-group">
      <div class="row">
        <div class="col-xs-10">
          <label for="tags">Tags</label>
          <input name="tags" value="<?php echo $_REQUEST['tags']; ?>" placeholder="Comma-separated" class="form-control"/>
        </div>
      </div>
    </div>
  </div>

  <input type="submit" value="Save" class="btn btn-default" />
</form>
</div>
<script language="javascript" src="/js/jquery.min.js"></script>
<script language="javascript" src="/js/script.js"></script>
</body>
</html>
