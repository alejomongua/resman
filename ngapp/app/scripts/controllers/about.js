'use strict';

/**
 * @ngdoc function
 * @name resmanNgApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the resmanNgApp
 */
angular.module('resmanNgApp')
  .controller('AboutCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
  });
