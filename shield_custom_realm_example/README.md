Example Custom Realm Plugin for User Authentication in Shield
=====

You can integrate [Shield](https://www.elastic.co/products/watcher) with external 
authentication systems by implementing a 
_custom realm_. A custom realm is an Elasticsearch plugin that interacts with an external 
system to confirm the identity of users trying to access nodes protected by Shield. 
 
Sample code that illustrates the structure and implementation of a custom realm is 
provided in the [shield-custom-realm-example](https://github.com/elastic/shield-custom-realm-example) 
repository. You can use this code as a starting point for creating your own realm.

For more information about creating and using custom realms, see 
[Integrating with Other Authentication Systems]
(https://www.elastic.co/guide/en/shield/2.0.0-beta2/custom-realms.html) in the Shield
Reference. For more information about building Elasticsearch Plugins, see 
[Elasticsearch Plugins and Integrations]
(https://www.elastic.co/guide/en/elasticsearch/plugins/2.0/index.html). 