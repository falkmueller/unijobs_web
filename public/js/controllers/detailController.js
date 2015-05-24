(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('detailController', function($routeParams, $scope,  $sce){
            $scope.mapsrc = "";

            var uid = $routeParams.uid;
             GetJobDetails(uid, function(res){
                          $scope.$apply(function () {
                                $scope.uni = res;
                                $scope.mapsrc = $sce.trustAsResourceUrl("http://www.openstreetmap.org/export/embed.html?bbox=" + res.unilong.value + "," + res.unilat.value + "&layer=mapnik&marker=" + res.unilat.value + "," + res.unilong.value + "");
                             });
                      });
        });
    });
}(define));