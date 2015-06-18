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

function htmlEscape(str) {
    return String(str)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(new RegExp('\r?\n','g'), '<br />');
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

function Console(headline, Message){
    $("#console").append("<div class=\"headline\">" + headline + "</div>");
    $("#console").append("<div class=\"body\">" + htmlEscape(Message) + "</div>");
}

/*****************************************
 * init
 * ****************************************/
function initialize(){
    $("#toggle_console").click(function(){
        toggle_console();
    });
}

function toggle_console(){
    if ($("#console").is(":visible")){
        //ausblenden
        $("#console").addClass("hide");
        $("#toggle_console").removeClass("in");
    } else {
        //einblenden
        $("#console").removeClass("hide");
         $("#toggle_console").addClass("in");
    }
}

/*****************************************
 * Sparql Functions
 * ****************************************/

function AddJob(Apiuser, ApiPassword, Job){
               var jobId = GetRandom();
    
             var query = "PREFIX dc: <http://tomcat.falk-m.de/> \n"
                          + " PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#>\n"
                          + " PREFIX dbres: <http://dbpedia.org/resource/>\n"
                          + " PREFIX dbonto: <http://dbpedia.org/ontology/>\n"
                          + " PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n"
                          + " INSERT DATA { dc:Job_" + jobId + "\n"    
				+ " rdf:type onto:job;\n"
                                + " onto:title \"" + Job.title + "\";\n"
                                + " onto:uid \"" + jobId + "\";\n"
                                + " onto:description \"" + Job.description + "\";\n"
                                + " onto:in_uni <" + Job.uni + ">;\n"
                                + " onto:faculty \"" + Job.faculty + "\";\n"
                                + " onto:salaryscale \"" + Job.salaryscale + "\";\n"
                                + "onto:ismanual true. \n"
                            + "}";
                
                Console("Abruf aller unis von DBPedia", query);
              
               $.ajax({
                url: "http://" + Apiuser + ":" + ApiPassword + "@" + location.host +"/fuseki/ds/update",
                method: "POST",
                data: {update: query},
                xhrFields: {
                    withCredentials: true
                },
                success: function(res){
                    AddMessage('AddJob','Die Stelle wurde eingestellt','success');     
                },
                error: function(res){
                    AddMessage('AddJob','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei AddJob", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                }
              });
}

function GetAllUnis(CallBackFn){
    
    var query = "PREFIX  onto: <http://dbpedia.org/ontology/>\n" +
                "prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
                "PREFIX dbres: <http://dbpedia.org/resource/>\n" +
                "PREFIX prop: <http://dbpedia.org/property/>\n" + 
                "\n" +
                "SELECT ?uni ?name (group_concat(distinct ?city_name; separator = \", \") AS ?CITY) (group_concat(distinct ?state_name ; separator = \", \") AS ?STATE) \n" +
                "WHERE\n" +
                "  { ?uni rdf:type onto:University .\n" +
                "    ?uni prop:country dbres:Germany.\n" +
                "    ?uni prop:name ?name. \n" +
                "    OPTIONAL { \n" +
                "       ?uni onto:city ?city.  \n" +
                "       ?city rdfs:label ?city_name. \n" +
                "       OPTIONAL { \n" +
                "           ?city prop:bundesland ?state_name. \n" +
                "           FILTER(langMatches(lang(?state_name), \"EN\")) \n" +
                "       } \n" +
                "       FILTER(langMatches(lang(?city_name), \"en\")) \n" +
                "     } \n" +
                "     FILTER(langMatches(lang(?name), \"en\"))\n" +
                "  }\n" + 
                " GROUP BY ?uni ?name \n" +
                " ORDER BY ?STATE ?CITY ?name";
        
        Console("Abruf aller Unis von DBPedia", query);
        
        var url = "http://dbpedia.org/sparql?default-graph-uri=http%3A%2F%2Fdbpedia.org&query=" + escape(query) + "&format=json";
   
               $.ajax({
                url: url,
                method: "GET",
                dataType: "jsonp",
                success: function(res){
                    CallBackFn(res.results.bindings);
            },
                error: function(res){
                    AddMessage('AddJob','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei GetAllUnis", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                }
              });
}

function GetJobs(cFrom, cPP, CallBackFn){
    var query = "PREFIX dc: <http://tomcat.falk-m.de/> \n" +
                "PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#> \n" +
                "PREFIX dbonto: <http://dbpedia.org/ontology/> \n" +
                "PREFIX dbres: <http://dbpedia.org/resource/> \n" +
                "PREFIX dbprop: <http://dbpedia.org/property/> \n" +
                "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
                "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n" +
                "select ?job ?uni ?city ?uid ?jobtitle ?uniname ?cityname \n" +
                "WHERE { ?job  rdf:type onto:job; \n" +
                "   onto:in_uni ?uni; \n" +
                "   onto:title ?jobtitle; \n" +
                "   onto:uid ?uid. \n" +
                "   SERVICE <http://dbpedia.org/sparql/> { ?uni dbonto:city ?city. \n" +
                "               ?uni dbprop:name ?uniname. \n" +
                "               ?city rdfs:label ?cityname \n" +
                "   }. \n" +
                " FILTER(langMatches(lang(?cityname), \"EN\")). \n" +
                " FILTER(langMatches(lang(?uniname), \"EN\")) \n" +
                "}" + 
                "LIMIT   " + cPP +
                "OFFSET  " + cFrom;
        
        Console("Abruf aller Jobs", query);
              
               $.ajax({
                url: "/fuseki/ds/query",
                method: "POST",
                data: {query: query},
                success: function(res){
                    CallBackFn(res.results.bindings);  
            },
                error: function(res){
                    AddMessage('AddJob','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei getJobs", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                    }
              });
}

function GetJobDetails(uid, CallBackFn){
    var query = "PREFIX dc: <http://tomcat.falk-m.de/> \n" +
                "PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#> \n" +
                "PREFIX dbonto: <http://dbpedia.org/ontology/> \n" +
                "PREFIX dbres: <http://dbpedia.org/resource/> \n" +
                "PREFIX dbprop: <http://dbpedia.org/property/> \n" +
                "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
                "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n" +
                "PREFIX foaf: <http://xmlns.com/foaf/0.1/> \n" +
                "PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> \n" +
                "select * \n" +
                "WHERE { ?job  rdf:type onto:job; \n" +
                "   onto:uid \"" + uid + "\"; \n" +
                "   onto:in_uni ?uni; \n" +
                "   onto:title ?jobtitle; \n" +
                "   onto:description ?jobdescription; \n" +
                "   onto:uid ?uid. \n" +
                "   SERVICE <http://dbpedia.org/sparql/> { ?uni dbonto:city ?city; \n" +
                "                       dbprop:name ?uniname. \n" +
                "                       OPTIONAL{ ?uni dbprop:website ?uniwebsite}. \n" +
                "                       ?city rdfs:label ?cityname. \n" +
                "                       OPTIONAL{?uni foaf:depiction ?unilogo}. \n" +
                "                       OPTIONAL{?uni geo:lat ?unilat}. \n" +
                "                       OPTIONAL{?uni geo:long ?unilong} \n" +
                "                       OPTIONAL{?city dbprop:bundesland ?state. FILTER(langMatches(lang(?state), \"EN\"))} \n" +
                "   }. \n" +
                " FILTER(langMatches(lang(?cityname), \"EN\")). \n" +
                " FILTER(langMatches(lang(?uniname), \"EN\")) \n" +
                "}";
        
        Console("Abruf von Job: " + uid, query);
              
               $.ajax({
                url: "/fuseki/ds/query",
                method: "POST",
                data: {query: query},
                success: function(res){
                    CallBackFn(res.results.bindings[0]);  
            },
                error: function(res){
                    AddMessage('AddJob','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei GetJobDetails", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                }
              });
}