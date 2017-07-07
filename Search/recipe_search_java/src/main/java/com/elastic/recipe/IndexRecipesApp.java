package com.elastic.recipe;

import java.io.File;
import java.io.IOException;
import java.net.InetAddress;
import java.nio.file.Files;

import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.transport.InetSocketTransportAddress;
import org.elasticsearch.transport.client.PreBuiltTransportClient;


/**
 */
public class IndexRecipesApp {

    public static void main(String[] args) {
        //System.out.println("IndexData app");
        File jsonDir = new File("data");
        File[] files = jsonDir.listFiles(
                (dir, name) -> {
                    return name.toLowerCase().endsWith(".json");
                }
        );

        // return if nothing to do
        if (files.length == 0) { return; }

        try {
            // create client for localhost es
            TransportClient client = new PreBuiltTransportClient(Settings.EMPTY)
                    .addTransportAddress(new InetSocketTransportAddress(InetAddress.getByName("localhost"), 9300));

            // iterate through json files, indexing each
            for (int n = 0; n < files.length; n++) {
                String json = new String(Files.readAllBytes(files[n].toPath()));
                IndexResponse response = client.prepareIndex("recipes", "recipe").setSource(json).get();
                String _index = response.getIndex();
                String _type = response.getType();
                String _id = response.getId();
                long _version = response.getVersion();
            }

            // close es client
            client.close();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

}
