const elasticsearch = require('elasticsearch')
var es_client = new elasticsearch.Client({
    host: 'localhost:9200'
});

var fs = require('fs')
var path = './data'
fs.readdir(path, (err, items) => {
    items.forEach(element => {
        fs.readFile(path + '/' + element, 'utf8', (err, content) => {
            es_client.index({ 
                index : 'recipes', 
                type : 'doc', 
                body: content});
        });
    });
})