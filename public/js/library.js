/*****************************************
 * General Functions
 * ****************************************/
function GetRandom(){
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
    return v.toString(16);
    });
}

function RemoveMessages(){
  $('div[id^="message_"]').remove(); 
}

function AddMessage(key, message, type){
     var time = '5000';
    var $container = $('#messagecontainer');
    
    $("#message_" + key).remove();
    
    var html = $('<div role="alert" id="message_' + key + '" class="alert alert-' + type + ' alert-dismissible fade in">' + message + '</div>');
    
    html.on('click', function () { $(this).remove(); });
    $container.append(html);

    setTimeout(function () {
      $container.children('.alert').first().remove();
    }, time);
}

/*****************************************
 * Sparql Functions
 * ****************************************/

function AddJob(Apiuser, ApiPassword, Job){
               var jobId = GetRandom();
    
             var data = {update: "PREFIX dc: <http://leemia.de/> "
                          + " PREFIX  onto: <http://localhost:8080/unijobs/public/ontology.rdf#>"
                          + " PREFIX dbres: <http://dbpedia.org/resource/>"
                          + " PREFIX dbonto: <http://dbpedia.org/ontology/>"
                          + " PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
                          + " INSERT DATA { dc:Job_" + jobId + ""    
				+ " rdf:type onto:job;"
                                + " onto:title \"" + Job.title + "\";"
                                + " onto:description \"" + Job.description + "\";"
                                + " onto:in_uni <" + Job.uni + ">"
                            + ".}"};
              
               $.ajax({
                url: "http://" + Apiuser + ":" + ApiPassword + "@localhost:8080/fuseki/ds/update",
                method: "POST",
                data: data,
                xhrFields: {
                    withCredentials: true
                },
                success: function(res){
                    AddMessage('AddJob','Die Stelle wurde eingestellt','success');     
                },
                error: function(res){
                    AddMessage('AddJob','Es ist ein Fehler aufgetreten','danger');
                    console.log(res);}
              });
}

function GetAllUnis(CallBackFn){
    var query = "PREFIX  onto: <http://dbpedia.org/ontology/>\n" +
                "prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
                "PREFIX dbres: <http://dbpedia.org/resource/>\n" +
                "PREFIX prop: <http://dbpedia.org/property/>\n" + 
                "\n" +
                "SELECT ?uni ?name \n" +
                "WHERE\n" +
                "  { ?uni rdf:type onto:University .\n" +
                "    ?uni prop:country dbres:Germany.\n" +
                "    ?uni prop:name ?name. \n" +
                "  }\n";
        
        var url = "http://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=" + escape(query) + "&format=json";
   
               $.ajax({
                url: url,
                method: "GET",
                success: function(res){
                    CallBackFn(res.results.bindings);
            },
                error: function(res){console.log(res);}
              });
}

function GetJobs(CallBackFn){
    var data = {query: "SELECT ?subject ?predicate ?object WHERE {?subject ?predicate ?object} LIMIT 25"};
              
               $.ajax({
                url: "http://localhost:8080/fuseki/ds/query",
                method: "POST",
                data: data,
                success: function(res){console.log(res.results.bindings); 
                    CallBackFn(res.results.bindings);  
            },
                error: function(res){console.log(res);}
              });
}

/*EXMLPE Join Query*/
//PREFIX dc: <http://leemia.de/> 
//PREFIX dbres: <http://dbpedia.org/resource/>
//PREFIX  onto: <http://dbpedia.org/ontology/>
//select ?u ?s
//WHERE { dc:test  dc:uni ?u .
//SERVICE <http://dbpedia.org/sparql/> { ?u onto:city ?s.} 
//}