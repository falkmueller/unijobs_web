(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('detailController', function($routeParams, $scope,  $sce){
            $scope.mapsrc = "";
            
            $scope.renderHtml = function(html_code)
            {
                return $sce.trustAsHtml(html_code);
            };

            var uid = $routeParams.uid;
             GetJobDetails(uid, function(res){
                          $scope.$apply(function () {
                                $scope.uni = res;
                                if (res.unilong){
                                    $scope.mapsrc = $sce.trustAsResourceUrl("http://www.openstreetmap.org/export/embed.html?bbox=" + res.unilong.value + "," + res.unilat.value + "&layer=mapnik&marker=" + res.unilat.value + "," + res.unilong.value + "");
                                 
                                } 

                                $scope.DescHtml = $sce.trustAsHtml($scope.uni.jobdescription.value);
                             });
                      });
                      
             GetJobKeyWords(uid, function(res){
                          $scope.$apply(function () {
                                $scope.keywords = res;
                                console.log(res);
                             });
                      });
        });
    });
}(define));