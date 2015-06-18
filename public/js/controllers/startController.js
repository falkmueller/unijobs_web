(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('startController', function($scope, $http){
            
            $scope.from = 0;
            $scope.pp = 10;
            
            $scope.loadmore = function(op){
                $scope.from = $scope.from + ($scope.pp*op);
                if ($scope.from < 0){$scope.from = 0;} 
                GetJobs($scope.from, $scope.pp, function(res){
                $scope.$apply(function () {
                      $scope.items = res;
                   });
                });
            };
            
            $scope.loadmore(0);

        });
    });
}(define));