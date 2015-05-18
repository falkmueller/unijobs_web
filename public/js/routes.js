app.config(function($routeProvider) {
    $routeProvider.
      when('/start', {
        templateUrl: 'templates/start.html',
        controller: 'StartController',
        accessLevel: 0
      }).
     otherwise({
        redirectTo: '/start'
      });
  });
