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

/**
 * bootstraps angular onto the window.document node
 */
define([
    'require',
    'angular',
    'jquery',
    'library',
    'app',
    'routes'
], function () {
    'use strict';
    
    require(['vendor/domReady!', 'library'], function () {
        initialize();
    });
});