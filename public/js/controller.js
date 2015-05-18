app.controller('StartController', function($scope){

    var data = {query: "SELECT ?subject ?predicate ?object WHERE {?subject ?predicate ?object} LIMIT 25"};
              
               $.ajax({
                url: "http://localhost:8080/fuseki/ds/query",
                method: "POST",
                data: data,
                success: function(res){console.log(res);},
                error: function(res){console.log(res);}
              });
});

app.controller('AddController', function($scope){
    $scope.AddEntity = function(Entity){
         console.log(Entity);
         
          data = {update: "PREFIX dc: <http://leemia.de/> INSERT DATA { dc:" + Entity.kennung + "    dc:title    \"" + Entity.testtext + "\" ; dc:creator  \"" + Entity.testtext + "\" .}"};
              
               $.ajax({
                url: "http://" + Entity.benutzername + ":" + Entity.passwort + "@localhost:8080/fuseki/ds/update",
                method: "POST",
                data: data,
                xhrFields: {
                    withCredentials: true
                },
                success: function(res){console.log(res);},
                error: function(res){console.log(res);}
              });
     }
});