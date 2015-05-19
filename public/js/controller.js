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