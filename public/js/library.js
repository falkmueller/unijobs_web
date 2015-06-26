var PREFIXE = "PREFIX dc: <http://tomcat.falk-m.de/> \n" +
                "PREFIX  onto: <http://tomcat.falk-m.de/unijobs/public/ontology.rdf#> \n" +
                "PREFIX dbonto: <http://dbpedia.org/ontology/> \n" +
                "PREFIX dbres: <http://dbpedia.org/resource/> \n" +
                "PREFIX dbprop: <http://dbpedia.org/property/> \n" +
                "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
                "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n" +
                "PREFIX foaf: <http://xmlns.com/foaf/0.1/> \n" +
                "PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> \n";

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
    
             var query = PREFIXE 
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
    
    var query = PREFIXE +
                "SELECT ?uni ?name (group_concat(distinct ?city_name; separator = \", \") AS ?CITY) (group_concat(distinct ?state_name ; separator = \", \") AS ?STATE) \n" +
                "WHERE\n" +
                "  { ?uni rdf:type dbonto:University .\n" +
                "    ?uni dbprop:country dbres:Germany.\n" +
                "    ?uni dbprop:name ?name. \n" +
                "    OPTIONAL { \n" +
                "       ?uni dbonto:city ?city.  \n" +
                "       ?city rdfs:label ?city_name. \n" +
                "       OPTIONAL { \n" +
                "           ?city dbprop:bundesland ?state_name. \n" +
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

function GetJobs(cFrom, cPP, CallBackFn, SearchValue){
    
    var SeachQueryPart = "";
    if (SearchValue){SeachQueryPart = GetSeachQueryPart(SearchValue);}
    
    var query = PREFIXE +
                "select ?job ?uni ?city ?uid ?jobtitle ?uniname ?cityname ?salaryscale ?unilogo \n" +
                "WHERE { " +
                "   SERVICE <http://dbpedia.org/sparql/> { \n" +
                "               ?uni rdf:type dbonto:University. \n" +
                "               ?uni dbprop:country dbres:Germany. \n" +
                "               ?uni dbonto:city ?city. \n" +
                "               ?uni dbprop:name ?uniname. \n" +
                "               ?city rdfs:label ?cityname \n" +
                "               OPTIONAL{?uni foaf:depiction ?unilogo}. \n" +
                "   }. \n" +
                "?job  rdf:type onto:job; \n" +
                "   onto:in_uni ?uni; \n" +
                "   onto:title ?jobtitle;  \n" +
                "   onto:salaryscale ?salaryscale; \n" +
                "   onto:uid ?uid; \n" +
                "   onto:description ?jobdescription. \n" +
                " FILTER(langMatches(lang(?cityname), \"EN\")). \n" +
                " FILTER(langMatches(lang(?uniname), \"EN\")) \n" +
                SeachQueryPart +
                "}" + 
                "LIMIT   " + cPP + " " +
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

function GetSeachQueryPart(Searchvalue){
    Searchvalue = Searchvalue.replace("\"", "");
    Searchvalue = Searchvalue.replace("\n", " ");
    
    var sv = Searchvalue.split(" "); 
    var querystring = "";
    
    for (var i = 0; i < sv.length; i++) {
        if (querystring !== ""){querystring += " && ";}
   
        querystring += "(regex(concat(\"\\\\b\", ?city, \"\\\\b\"), \"" + sv[i] + "\", \"i\") ||\n"
                                + " regex(concat(\"\\\\b\", ?uniname, \"\\\\b\"), \"" + sv[i] + "\", \"i\") || "
                                + " regex(concat(\"\\\\b\", ?jobtitle, \"\\\\b\"), \"" + sv[i] + "\", \"i\") || "
                                + " regex(concat(\"\\\\b\", ?jobdescription, \"\\\\b\"), \"" + sv[i] + "\", \"i\") ) ";
   
    }
    
    return "FILTER(" + querystring + ")";
    
     
    
}

function GetJobDetails(uid, CallBackFn){
    var query = PREFIXE +
                "select * \n" +
                "WHERE { ?job  rdf:type onto:job; \n" +
                "   onto:uid \"" + uid + "\"; \n" +
                "   onto:in_uni ?uni; \n" +
                "   onto:title ?jobtitle; \n" +
                "   onto:description ?jobdescription; \n" +
                "   onto:salaryscale ?salaryscale; \n" +
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
                "   OPTIONAL{?job onto:url ?url;}." +
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

function GetJobKeyWords(uid, CallBackFn){
    var query = PREFIXE +
                "select * \n" +
                "WHERE { ?job  rdf:type onto:job; \n" +
                "   onto:uid \"" + uid + "\"; \n" +
                "   onto:keywords ?k. \n" +
                "   ?k onto:Word ?word; \n" +
                "   onto:isconcept ?isconcept. \n" +
               "}";
        
        Console("Abruf von JobKeyWords: " + uid, query);
              
               $.ajax({
                url: "/fuseki/ds/query",
                method: "POST",
                data: {query: query},
                success: function(res){
                    CallBackFn(res.results.bindings);  
            },
                error: function(res){
                    AddMessage('GetJobKeyWords','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei GetJobKeyWords", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                }
              });
}

function filter_GetSalaryscale(CallBackFn){
    var query = PREFIXE +
                "select ?salaryscale\n" +
                "WHERE {  \n" +
                "    ?job  rdf:type onto:job.\n" +
                "    ?job onto:salaryscale ?salaryscale;\n" +
                "}\n" +
                "GROUP BY ?salaryscale\n";

        
        Console("Abruf von filter_GetSalaryscale: ", query);
              
               $.ajax({
                url: "/fuseki/ds/query",
                method: "POST",
                data: {query: query},
                success: function(res){
                    var result = res.results.bindings;
                     result.sort(function(a, b){return parseInt(a.salaryscale.value) - parseInt(b.salaryscale.value)});
                    CallBackFn(result);  
            },
                error: function(res){
                    AddMessage('filter_GetSalaryscale','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei filter_GetSalaryscale", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                }
              });
}


function filter_GetUnisAndCitys(CallBackFn){
    var query =  PREFIXE + 
                "select ?uni ?uniname ?cityname ?city\n" +
                "WHERE {  \n" +
                "   SERVICE <http://dbpedia.org/sparql/> { \n" +
                "    		?uni rdf:type dbonto:University.\n" +
                "    		?uni dbprop:country dbres:Germany.\n" +
                "            ?uni dbprop:name ?uniname. \n" +
                "    		?uni dbonto:city ?city.\n" +
                "    		?city rdfs:label ?cityname\n" +
                "               }. \n" +
                "    ?job  rdf:type onto:job.\n" +
                "    ?job onto:in_uni ?uni;\n" +
                " FILTER(langMatches(lang(?uniname), \"EN\")) .\n" +
                " FILTER(langMatches(lang(?cityname), \"EN\")).\n" +
                "}\n" +
                "GROUP BY ?uni ?uniname ?cityname ?city\n";

        Console("Abruf von filter_GetUnisAndCitys: ", query);
              
               $.ajax({
                url: "/fuseki/ds/query",
                method: "POST",
                data: {query: query},
                success: function(res){
                    var result = {unis: [], cities: []};
                    var uniqueCitys = [];
                    var uniqueUnis = [];
                    
                    for (var i = 0; i < res.results.bindings.length; i++) {
                        if(uniqueUnis.indexOf(res.results.bindings[i].uniname.value) < 0){
                            uniqueUnis.push(res.results.bindings[i].uniname.value);
                            result.unis.push({uni: res.results.bindings[i].uni.value, uniname: res.results.bindings[i].uniname.value});
                        }
                        
                        if(uniqueCitys.indexOf(res.results.bindings[i].cityname.value) < 0){
                            uniqueCitys.push(res.results.bindings[i].cityname.value);
                            result.cities.push({city: res.results.bindings[i].city.value, cityname: res.results.bindings[i].cityname.value});
                        }
                    }
                    
                    uniqueUnis.sort();
                    result.unis.sort(function(a, b){return uniqueUnis.indexOf(a.uniname) - uniqueUnis.indexOf(b.uniname)});
                    uniqueCitys.sort();
                    result.cities.sort(function(a, b){return uniqueCitys.indexOf(a.cityname) - uniqueCitys.indexOf(b.cityname)});
                    
                    CallBackFn(result);  
            },
                error: function(res){
                    AddMessage('filter_GetUnisAndCitys','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei filter_GetUnisAndCitys", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                }
              });
}

function filter_GetKeyWords(CallBackFn){
    var query = PREFIXE +
                "select ?babelres (SAMPLE(?Word) AS ?WORD) (SAMPLE(?isconcept) AS ?ISCONCEPT) (COUNT(?babelres) AS ?ELEMENTCOUNT)\n" +
                "WHERE {  \n" +
                "    ?job  rdf:type onto:job.\n" +
                "    ?job onto:keywords ?keywords.\n" +
                "    ?keywords onto:Word ?Word.\n" +
                "    ?keywords onto:isconcept ?isconcept.\n" +
                "    ?keywords onto:babelres ?babelres.\n" +
                "}\n" +
                "GROUP BY ?babelres\n" +
                "HAVING (COUNT(?babelres) < 20)" +
                "ORDER BY DESC(?ELEMENTCOUNT)\n" +
                "LIMIT 100\n";

        
        Console("Abruf von filter_GetKeyWords: ", query);
              
               $.ajax({
                url: "/fuseki/ds/query",
                method: "POST",
                data: {query: query},
                success: function(res){
                    CallBackFn(res.results.bindings);  
            },
                error: function(res){
                    AddMessage('filter_GetKeyWords','Es ist ein Fehler aufgetreten','danger');
                    Console("Fehler bei filter_GetKeyWords", "StatusCode: " + res.status + "; StatusText: " + res.statusText + "\n" + res.responseText);
                }
              });
}