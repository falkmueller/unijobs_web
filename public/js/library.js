/*js Library*/

function test(){
    $.ajax({
                url: "http://localhost:8080/fuseki/ds/get",
                method: "GET",
                success: function(res){console.log(res);},
                error: function(res){console.log(res);}
              });
              
              //query=%0A%0ASELECT+%3Fsubject+%3Fpredicate+%3Fobject%0AWHERE+%7B%0A++%3Fsubject+%3Fpredicate+%3Fobject%0A%7D%0ALIMIT+25
              var data = {query: "SELECT ?subject ?predicate ?object WHERE {?subject ?predicate ?object} LIMIT 25"};
              
               $.ajax({
                url: "http://localhost:8080/fuseki/ds/query",
                method: "POST",
                data: data,
                success: function(res){console.log(res);},
                error: function(res){console.log(res);}
              });
}