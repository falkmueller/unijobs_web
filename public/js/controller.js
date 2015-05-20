app.controller('StartController', function($scope, $http){

    var data = {query: "SELECT ?subject ?predicate ?object WHERE {?subject ?predicate ?object} LIMIT 25"};
              
              //$scope.items = [1,2,3];
              
              GetJobs(function(res){
                  $scope.$apply(function () {
                        $scope.items = res;
                     });
              });
              
});

app.controller('InfoController', function($scope){
    
});

app.controller('AddController', function($scope){
    $scope.AddEntity = function(Entity){
         
         AddJob(Entity.benutzername, Entity.passwort, Entity);
     };
     
     GetAllUnis(function(res){
                  $scope.$apply(function () {
                        $scope.unis = res;
                     });
              });
});

app.controller('DetailController', function($routeParams, $scope,  $sce){
    $scope.mapsrc = "";
    
    var uid = $routeParams.uid;
     GetJobDetails(uid, function(res){
                  $scope.$apply(function () {
                        $scope.uni = res;
                        $scope.mapsrc = $sce.trustAsResourceUrl("http://www.openstreetmap.org/export/embed.html?bbox=" + res.unilong.value + "," + res.unilat.value + "&layer=mapnik&marker=" + res.unilat.value + "," + res.unilong.value + "");
                     });
              });
});
