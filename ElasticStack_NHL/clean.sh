curl -XDELETE localhost:9200/nhl
curl -XPUT localhost:9200/nhl -d '{
  "mappings": {
    "play": {

        "dynamic_templates": [
            { "notanalyzed": {
                  "match":              "*", 
                  "match_mapping_type": "string",
	  	  "mapping" : {
		      "type" : "string", "index" : "analyzed", "omit_norms" : true,
		      "fields" : {
			"raw" : {"type": "string", "index" : "not_analyzed"}
		      }
		   }
               }
            }
          ]
       }
   }
}'



