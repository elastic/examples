# Kibana Custom Tile Layers

This is a demo of running your own WMS tile layer that Kibana can pull
a "map" layer from.

## Building

First put some shapefiles into the build directory or comment out the
COPY line in the Dockerfile.

    docker build --tag example/geoserver .

## Running

    docker run -p 8080:8080 example/geoserver

Or, if you commented out the COPY line in the Dockerfile, mount a local directory:

    docker run -p 8080:8080 -v $HOME/my_maps:/opt/geoserver/data_dir example/geoserver

Note: add a "-d" to daemonize.

## Configuration

From within Geoserver:

1. Login to geoserver: http://<hostname>:8080/geoserver (defaults are: admin/geoserver)
2. Click Workspace -> Add new workspace -> Make up a name and uri prefix
3. Click Stores -> Create "Store" from Shapefile or directory of Shapefiles
4. Click "Browse" to find the "shapefiles" directory in the data_dir
5. Click "Publish" to create a map.
   1. Under "Bounding Boxes" click "Compute from data" and "Compute from native bounds"
   2. Click "Save"
6. On left hand side menu click "Tile Layers"
7. Select the "Preview" drop down and select "EPSG:4326 / png"
8. View your new layer.

## Caching

While caching is enabled by default, without further setup the server will use
a default caching strategy that is file based and located in the default data directory. 
If the data directory is not mounted as a volume it will use the containers emphemeral 
storage.  To improve caching persistance and efficiency either mount the data directory
or create a new BlobStore mounted to a fast (SSD/RAID) persistent disk.
