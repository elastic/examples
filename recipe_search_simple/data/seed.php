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

$batchLines = [];
$iter = new DirectoryIterator(__DIR__ . "/recipes");
foreach ($iter as $item) {
    if (!$item->isDot()
        && $item->isFile() 
        && $item->isReadable()) {

        $filepath = $item->getPathname();
        $basename = $item->getBasename(".json");

        $batchLines[] = '{ "index": { "_id": "' . $basename . '" } }';
        $batchLines[] = json_encode(json_decode(file_get_contents($filepath)));
    }
}

$params['body']  = implode("\n", $batchLines);

// Bulk load seed data
$ret = $client->bulk($params);
