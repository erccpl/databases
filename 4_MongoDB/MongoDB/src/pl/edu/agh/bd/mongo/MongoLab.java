package pl.edu.agh.bd.mongo;

import com.mongodb.Block;
import com.mongodb.MongoClient;
import com.mongodb.client.MapReduceIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import static com.mongodb.client.model.Filters.*;

import java.net.UnknownHostException;
import java.util.Arrays;
import com.mongodb.client.model.Accumulators;
import com.mongodb.client.model.Aggregates;
import org.bson.Document;



public class MongoLab {

    private MongoCollection<Document> jeopardyCollection;

    public MongoLab() throws UnknownHostException {
        MongoClient mongoClient = new MongoClient();
        MongoDatabase db = mongoClient.getDatabase("jeopardy");
        jeopardyCollection = db.getCollection("question");
    }

    private Block<Document> printBlock = (document) -> {
            System.out.println(document.toJson());
    };


    public static void main(String[] args) throws UnknownHostException {
        MongoLab mongoLab = new MongoLab();

        mongoLab.dummyQuery();

        System.out.println("Zapytanie proste:");
        System.out.println("Ile pytań w rundzie ‘Double Jeopardy’ z kategorii ‘Anatomy’ było wartych więcej niż $400?");
        mongoLab.simpleQuery();
        System.out.println("\n");


        System.out.println("Zapytanie z wykorzystaniem agregacji:");
        System.out.println("Ile pytań z kategorii ‘Anatomy’ lub ‘Medicine’ o wartości $100 lub $200 padło w rundzie ‘Jeopardy!’?");
        mongoLab.aggregationQuery();
        System.out.println("\n");


        System.out.println("Zapytanie z wykorzystaniem mapReduce:");
        System.out.println("Jaka była łączna wartość pytań z kategrii 'History' w każdym odcinku?");
        mongoLab.mapReduceQuery();
        System.out.println("\n");
    }


    public void dummyQuery() {
        //Funkcja wyłącznie w celu ominięcia logów
        System.out.println(jeopardyCollection.count(eq("category", "FAKE CATEGORY")));
        System.out.println("Rozpoczęcie zapytań\n");
    }


    private void simpleQuery() {
        long count = jeopardyCollection.count(
                and(
                        eq("category", "ANATOMY"),
                        eq("round", "Double Jeopardy!"),
                        gt("value", "$400")
                    )
        );
        System.out.println(count);
    }



    private void aggregationQuery() {
        jeopardyCollection.aggregate(
            Arrays.asList(
                    Aggregates.match(
                            and(
                                    in("category", Arrays.asList("ANATOMY", "MEDICINE")),
                                    eq("round", "Jeopardy!"),
                                    in("value", Arrays.asList("$100", "$200"))
                            )
                    ),
                    Aggregates.group("$show_number", Accumulators.sum("total", 1))
            )
        ).forEach(printBlock);
    }


    private void mapReduceQuery() {
        String mapFunction = "function() { emit( this.show_number, this.value); }";
        String reduceFunction = "function(key, values) {" +
                "            var newValues = values.map( " +
                "                function(x) {" +
                "                    return Number(x.replace(/[$, ,]/g,\"\"));" +
                "                } );" +
                "             return Array.sum(newValues);" +
                "    }";

       jeopardyCollection.mapReduce(mapFunction, reduceFunction)
                .filter(eq("category", "HISTORY"))
       .forEach(printBlock);

    }

}

