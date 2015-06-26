(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('startController', function($scope, $http){
            
            $scope.from = 0;
            $scope.pp = 10;
            
            
            $scope.SearchValue = "";
            $scope.filter = {};
            
            $scope.filter.salaryscale = "";
            $scope.filter.city = "";
            $scope.filter.uni = "";
            $scope.filter.keywords = [];
             
            $scope.SwitchKeyWord = function(keyres, index){
                
                if ($scope.filter.keywords.indexOf(keyres) < 0){
                    $scope.filter.keywords.push(keyres);
                } else {
                    $scope.filter.keywords.splice($scope.filter.keywords.indexOf(keyres), 1);
                }
                
                $("#filterbox_" + index).toggleClass("filter_selected");
                
                $scope.loadmore(0);
                
            }
            
            $scope.loadmore = function(op){
                if (op == 0){$scope.from = 0;}
                $scope.from = $scope.from + ($scope.pp*op);
                if ($scope.from < 0){$scope.from = 0;} 
                GetJobs($scope.from, $scope.pp, function(res){
                $scope.$apply(function () {
                      $scope.items = res;
                   });
                }, $scope.SearchValue, $scope.filter);
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