(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('startController', function($scope, $http){
            
            $scope.from = 0;
            $scope.pp = 10;
            $scope.SearchValue = "";
            
            $scope.loadmore = function(op){
                if (op == 0){$scope.from = 0;}
                $scope.from = $scope.from + ($scope.pp*op);
                if ($scope.from < 0){$scope.from = 0;} 
                GetJobs($scope.from, $scope.pp, function(res){
                $scope.$apply(function () {
                      $scope.items = res;
                   });
                }, $scope.SearchValue);
            };
            
            $scope.loadmore(0);
            
            filter_GetSalaryscale(function(res){
                $scope.$apply(function () {
                      $scope.SalaryscaleFilter = res;
                   });
                });

            filter_GetUnisAndCitys(function(res){
                $scope.$apply(function () {
                      $scope.unis = res.unis;
                      $scope.cities = res.cities;
                   });
                });
                
            filter_GetKeyWords(function(res){
                $scope.$apply(function () {
                      $scope.Keywords = res;
                   });
                });
        });
    });
}(define));