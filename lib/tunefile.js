// Generated by CoffeeScript 1.3.3
(function() {
  var CSON, configs, debug, newContext, pathUtil, vm, wheels, _;

  vm = require("vm");

  pathUtil = require('path');

  _ = require('underscore');

  CSON = require('cson');

  debug = require('./command').debug;

  wheels = require('./index');

  newContext = function() {
    var ctx;
    ctx = {};
    ctx.root = function(newRoot) {
      return prj.root = newRoot;
    };
    return vm.createContext(ctx);
  };

  this.configs = configs = function(file) {
    return CSON.parseFile(file, function(err, obj) {
      var ctx;
      ({
        sandbox: ctx = newContext(),
        filename: file
      });
      return ctx.project;
    });
  };

}).call(this);