const express = require('express')
const app = express()
const port = 3000

app.use(express.json());

var elasticsearch = require('elasticsearch')
var es_client = new elasticsearch.Client({
    host: 'localhost:9200'
});

app.get('/', (req, res) => {
    es_client.ping({
        requestTimeout: 1000
    }, function(error) {
        if (error) {
            res.send('Elasticsearch is down!');
        }
        else {
            res.send('Hello World! Elasticsearch is ready!');
        }
    });
})

app.post('/', (req, res) => {
    console.log(req.body);
    res.send('OK');
});

app.listen(port, () => console.log('Example app running on port ' + port));