/*js Library*/

function AddJob(Apiuser, ApiPassword, Job){
              data = {update: "PREFIX dc: <http://leemia.de/> INSERT DATA { dc:" + Job.kennung + "    dc:title    \"" + Job.testtext + "\" ; dc:creator  \"" + Job.testtext + "\" .}"};
              
               $.ajax({
                url: "http://" + Apiuser + ":" + ApiPassword + "@localhost:8080/fuseki/ds/update",
                method: "POST",
                data: data,
                xhrFields: {
                    withCredentials: true
                },
                success: function(res){console.log(res);},
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