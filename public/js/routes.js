app.config(function($routeProvider) {
    $routeProvider.
      when('/start', {
        templateUrl: 'templates/start.html',
        controller: 'StartController'
      }).
      when('/add', {
        templateUrl: 'templates/add.html',
        controller: 'AddController'
      }).
     when('/info', {
        templateUrl: 'templates/info.html',
        controller: 'InfoController'
      }).
     otherwise({
        redirectTo: '/start'
      });
  });
