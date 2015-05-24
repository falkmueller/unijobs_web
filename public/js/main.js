requirejs.config({
    baseUrl: 'js',
    paths: {
        vendor: 'vendor',
        angular: 'vendor/angular.min',
        'jquery': 'vendor/jquery-1.11.3.min'
    },
      shim: {
        angular: {
            exports : 'angular'
        },
        'vendor/angular-route': {
          deps: ['angular'],
          exports: 'angular'
        },
        'vendor/angular-animate': {
          deps: ['angular'],
          exports: 'angular'
        },
        'directives': {
          deps: ['angular'],
          exports: 'angular'
        }
  }
  
});

require(
    [
       'require',
        'angular',
        'jquery',
        'library',
        'app',
        'routes'
    ],
    function () {
        angular.bootstrap(document, ['app']);
        initialize();
    });

