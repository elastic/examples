This directory contains the files necessary to recreate the Café Canvas from Elastic{ON} 2018, and includes the actual consumption metrics from the conference.

To use this data you need an Elastic Stack running, and Canvas installed on the Kibana node.  Check out [the Canvas install instructions](http://canvas.elastic.co/stories/installing.html) to see how to install the latest version of Canvas.

## To load the data

Log into Kibana, and navigate over to your DevTools.  Paste into the DevTools the contents of the `elasticoffee-data.bulk` file, which starts like this:

```json
POST _bulk
{ "index" : { "_index" : "elasticoffee", "_type" : "doc", "_id" : "1" } }
{"sceneID": "2", "sceneData": "0", "entityID": "zwave.quad2", "quadId": 2, "quadMod": "1", "@timestamp": "2018-02-27T22:26:39Z", "beverageClass": "Hot Beverages", "beverage": "Latte", "beverageSide": "left", "beverageIndex": 5, "quantity": 1}
{ "index" : { "_index" : "elasticoffee", "_type" : "doc", "_id" : "2" } }
{"sceneID": "3", "sceneData": "0", "entityID": "zwave.quad1", "quadId": 1, "quadMod": "0", "@timestamp": "2018-02-27T22:26:39Z", "beverageClass": "Hot Beverages", "beverage": "Mocha", "beverageSide": "left", "beverageIndex": 2, "quantity": 1}
```

Then hit the little play button to load the data.

You can then paste in `POST /elasticoffee/_search` and execute that to see that it now has data.

## To load the Canvas workpad

Still in Kibana, navigate to the Canvas app (it looks like a little easel).  Click on the "workpads" on the bottom, which will pop up the workpad selector.  Here we see a tip: 

> Tip: Drag and drop a `JSON` exported workpad into this dialog to load new workpad from a file
> If you already have a workpad it will look like this ![existing workpad](./images/existing-workpads.png =300)

So simply drag and drop the `canvas-workpad-CafeCanvas.json` onto the pane, and it will upload.  Select the new workpad and the data should appear!

## Bonus Stuff!

We have also included the Home Assistant config, as well as the script that we used to link the buttons to the rest call.  You will need to tweak a bit if you want to use it with your home assistant instance, but it should show you how everything is plumbed together.  A couple quick notes is that your home assistant config likely has a different suffix for the zwcfg, and the Wallmote buttons will have different node IDs.

The coffeePressHandler.sh is what POSTs the data to Elasticsearch and assumes that these env vars are set, or if a `~/secrets.env` exists:

```code
creds="${COFFEE_PRESS_CREDENTIALS}"
hosts="${COFFEE_PRESS_HOSTS}"
endpoint="${COFFEE_PRESS_ENDPOINT}"
```

The credentials are of the form `user:password`, while the endpoint in this case was `elasticoffee/doc`

```console
elasticon-home-assistant/
├── automations
│   └── elasticon-automations.yaml
├── coffeePressHandler.sh
├── configuration.yaml
├── customize.yaml
├── groups.yaml
├── load-test.sh
├── options.xml
├── scripts.yaml
├── shell_commands
│   └── elasticon-shell_commands.yaml
├── zwcfg_0xf7001e9d.xml
└── zwscene.xml
```