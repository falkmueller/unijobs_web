(function(define){
    "use strict";
    define(["common/controllers"],function(controllers){
        controllers.controller('addController', function($scope){
            $scope.AddEntity = function(Entity){

                 AddJob(Entity.benutzername, Entity.passwort, Entity);
             };

             GetAllUnis(function(res){
                          $scope.$apply(function () {
                                $scope.unis = res;
                             });
                      });
        });
    });
}(define));