
(function(define){
    "use strict";  
    
    define([
    'angular',
    'vendor/bootstrap.min',
    'controllers/index',
    'vendor/angular-route',
    'vendor/angular-animate',
    'directives'],
    function(ng){
             
        var dependencies = [
            'controllers',
            'ngRoute',
            'ngAnimate',
             'linkactivation',
             'viewTitle'
        ];
        
        var app = ng.module('app', dependencies);
                
        return app;
    });
 
}(define));