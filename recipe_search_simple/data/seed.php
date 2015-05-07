<?php

require __DIR__ . '/../vendor/autoload.php';

use RecipeSearchSimple\Constants;

// Connect to local Elasticsearch node
$esPort = getenv('APP_ES_PORT') ?: 9200;
$client = new Elasticsearch\Client([
    'hosts' => [ 'localhost:' . $esPort ]
]);

// Delete index to clear out existing data
$deleteParams = [];
$deleteParams['index'] = Constants::ES_INDEX;

if ($client->indices()->exists($deleteParams)) {
    $client->indices()->delete($deleteParams);
}

// Setup bulk index request for seed data
$params = [];
$params['index'] = Constants::ES_INDEX;
$params['type']  = Constants::ES_TYPE;
$params['body']  = file_get_contents(__DIR__ . '/seed.txt');

// Bulk load seed data
$ret = $client->bulk($params);
