define(['app'], function (app) {
    'use strict';
    return app.config(function($routeProvider) {
    $routeProvider.
      when('/start', {
        templateUrl: 'templates/start.html',
        controller: 'startController'
      }).
      when('/add', {
        templateUrl: 'templates/add.html',
        controller: 'addController'
      }).
     when('/info', {
        templateUrl: 'templates/info.html',
        controller: 'infoController'
      }).
     when('/details/:uid', {
        templateUrl: 'templates/detail.html',
        controller: 'detailController'
      }).
     otherwise({
        redirectTo: '/start'
      });
  });
});
