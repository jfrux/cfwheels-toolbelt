// Generated by CoffeeScript 1.3.3
(function() {
  var CSON, Command, cli, clr, exec, fs, getLocalProject, getVersion, inWheelsProject, path, _,
    __slice = [].slice;

  fs = require('fs');

  path = require('path');

  exec = require('exec');

  CSON = require('cson');

  Command = require('commander').Command;

  clr = require('ansi-color').set;

  _ = require('underscore');

  exports.version = getVersion = function() {
    var pkg;
    fs = require('fs');
    path = require('path');
    pkg = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../package.json')));
    return pkg.version;
  };

  inWheelsProject = function() {
    var hasConfig;
    hasConfig = (require('./index')).Project.prototype.hasConfigFile();
    return hasConfig;
  };

  getLocalProject = function() {
    return new (require('./index')).Project;
  };

  _.extend(exports, cli = {
    finished: function(action, target) {
      return console.log(clr(action, 'blue'), target);
    },
    debug: function() {
      var msgs;
      msgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return console.log.apply(console, [clr('DEBUG', 'red')].concat(__slice.call(msgs)));
    },
    warning: function() {
      var msgs;
      msgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return console.log.apply(console, [clr('Warning', 'yellow')].concat(__slice.call(msgs)));
    },
    info: function() {
      var msgs;
      msgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return console.log.apply(console, [clr('Info', 'green')].concat(__slice.call(msgs)));
    },
    error: function() {
      var msgs;
      msgs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return console.log.apply(console, [clr('Error', 'red')].concat(__slice.call(msgs)));
    }
  });

  exports.run = function(argv) {
    var program;
    (program = new Command).version(getVersion()).usage('new APP_PATH [options]');
    program.command('new').description("Initialize " + (clr('Wheels', 'green')) + " in DIRECTORY").action(function() {
      var content, project, template;
      template = path.resolve(path.join('src', 'tunefile', "template.cson"));
      content = fs.readFileSync(template, 'utf-8');
      CSON.parse(content, function(err, obj) {
        var result;
        return result = CSON.parseSync(content);
      });
      project = getLocalProject();
      cli.info('Writing Tunefile');
      fs.writeFileSync('Tunefile', content, 'utf-8');
      cli.info('Downloading Latest CFWheels');
      project.getWheels();
      cli.info('Acquiring Railo Express');
      return project.getRailo(function(path) {
        return cli.info('Found Railo at ' + path);
      });
    });
    program.command('install').description("Downloads and installs Railo Express, and latest version of CFWheels").action(function() {
      var project;
      project = getLocalProject();
      if (project.missingModules().length > 0) {
        return project.installMissingModules();
      } else {
        return cli.info('No modules are missing.');
      }
    });
    program.command('*').description(" Aggregate bundles from the given packages (or all)").action(function() {});
    if (!process.argv.length) {
      program.help();
    }
    return program.parse(argv);
  };

}).call(this);