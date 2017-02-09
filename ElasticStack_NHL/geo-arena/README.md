
You can use this NHL data to make a pretty visualization of a Hockey arena that looks like this:

![Arena Viz](https://github.com/PhaedrusTheGreek/nhl-stats-elasticsearch/blob/master/geo-arena/arena-viz.png)

First, download and install [GeoServer](http://geoserver.org/)

If you want to encode your own image, you're on your own - but for the most part, here's how you do it:

[GDAL Translate](http://www.gdal.org/gdal_translate.html) tool was used to encode latitude/longitude into a tiff file from a png of a hockey arena:

```
gdal_translate -of GTiff -a_srs EPSG:4326 -a_ullr -105 45 105 -45 nhl_rink.gif nhl_rink_gtiff.tiff
gdalwarp -t_srs EPSG:4326 nhl_rink_gtiff.tiff nhl_rink.tiff
```

A hockey rink is 200 Feet by 85 Feet, so I calculated the top left corner at -100, 42.5, and added a bit of slack.

Note that the file extension must be `.tiff` or else geoserver won't browse it.

If you just want to use my arena tiff, then it's [available here](https://github.com/PhaedrusTheGreek/nhl-stats-elasticsearch/blob/master/geo-arena/arena.tiff). 

You can import the tiff into a GeoServer WMS layer somewhere in the GeoServer UI.

Finally, set up Kibana to point to the GeoServer IP like this (where my IP is blacked out):

![Kibana Config](https://github.com/PhaedrusTheGreek/nhl-stats-elasticsearch/blob/master/geo-arena/kibana-settings.png)



