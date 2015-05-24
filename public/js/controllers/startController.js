(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('startController', function($scope, $http){

            var data = {query: "SELECT ?subject ?predicate ?object WHERE {?subject ?predicate ?object} LIMIT 25"};

                      //$scope.items = [1,2,3];

                      GetJobs(function(res){
                          $scope.$apply(function () {
                                $scope.items = res;
                             });
                      });

        });
    });
}(define));