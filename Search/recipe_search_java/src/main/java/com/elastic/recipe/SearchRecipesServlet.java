package com.elastic.recipe;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.stream.JsonReader;
import org.elasticsearch.action.search.SearchRequestBuilder;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.transport.TransportAddress;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.transport.client.PreBuiltTransportClient;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Iterator;

/**
 * Created by daragies on 3/20/17.
 */
public class SearchRecipesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        doGetOrPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        doGetOrPost(request, response);
    }

    private void doGetOrPost(HttpServletRequest request, HttpServletResponse response) {
        TransportClient client = null;
        try {
            client = new PreBuiltTransportClient(Settings.EMPTY);
            client.addTransportAddress(new TransportAddress(InetAddress.getByName("localhost"), 9300));
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }

        StringBuffer buffer = new StringBuffer();
        String line = null;
        try {
            BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
            System.out.println(buffer.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }

        JsonObject json = new JsonParser().parse(buffer.toString()).getAsJsonObject();
        String search = json.get("search").getAsString();
        if (search == null || search.trim().length() == 0) { search = "*"; }
        String order = json.get("order").getAsString();
        int offset = json.get("offset").getAsInt();
        int limit = json.get("limit").getAsInt();

        // build elasticsearch search request
        SearchRequestBuilder builder = client.prepareSearch("recipes");
        builder.setTypes("doc");
        builder.setSearchType(SearchType.DFS_QUERY_THEN_FETCH);
        builder.setFrom(offset);
        builder.setSize(limit);
        builder.setQuery(QueryBuilders.simpleQueryStringQuery(search));

        SearchResponse res = builder.get();
        SearchHits hits = res.getHits();

        String source = "{ \n\"total\": " + hits.getTotalHits() + ",";
        source += "\"rows\": [";

        //String source = "[";
        Iterator<SearchHit> iterator =  hits.iterator();
        while (iterator.hasNext()) {
            SearchHit hit = iterator.next();
            source += hit.getSourceAsString();
            if (iterator.hasNext()) {
                source += ",\n";
            }
        }
        source += "]}";
        //source += "]";
        System.out.println(source);

        response.setContentType("application/json");
        response.setHeader("Content-Disposition", "inline");

        try {
        response.getWriter().println(source);
        } catch (IOException e) {
        e.printStackTrace();
        }

        client.close();
        }
}
