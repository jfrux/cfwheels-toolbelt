# This module holds everything related to interacting with brewer.js from 
# the shell, including the *[bin/brewer](#section-6)* utility, and 
# different [shell printing functions](#section-5).

# Essential modules are imported
fs = require 'fs'
path = require 'path'
exec = require 'exec'
CSON = require 'cson'
Command = require('commander').Command
clr = require('ansi-color').set
_ = require 'underscore'

# This function returns the version number from the *package.json* file.
exports.version = getVersion = ->
  fs = require 'fs'
  path = require 'path'
  pkg = JSON.parse fs.readFileSync path.resolve __dirname, '../package.json'
  pkg.version

# This function returns a `Project` object from the tunefile located
# in the current working directory.
inWheelsProject = ->
  hasConfig = (require './index').Project.prototype.hasConfigFile()

  return hasConfig

getLocalProject = ->
  new (require './index').Project
##### CLI utility functions
#
# These functions are used to standardize how certain types of
# of messages are displayed in the shell, are all exported and used
# throughout cfwheels.

_.extend exports, cli = {
  finished: (action, target) ->
    console.log clr(action, 'blue'), target
  
  debug: (msgs...) ->
    console.log clr('DEBUG', 'red'), msgs...
  
  warning: (msgs...) ->
    console.log clr('Warning', 'yellow'), msgs...
  
  info: (msgs...) ->
    console.log clr('Info', 'green'), msgs...
  
  error: (msgs...) ->
    console.log clr('Error', 'red'), msgs...
  
}

#### bin/wheels 
#
# Making heavy use of 
# [commander.js](http://visionmedia.github.com/commander.js/).
# A `run` function is exported, which takes the process argument list (`process.argv`)
# as arguments and executes a *Commander.js*'s Command object on them. The version is
# extracted using [`getVersion()`](#section-3) above.

exports.run = (argv) ->
  (program = new Command)
    .version(getVersion())
    .usage('new APP_PATH [options]')

  program
    .command('new')
    .description("Initialize #{clr('Wheels', 'green')} in DIRECTORY")
    .action ->
      template = path.resolve(path.join('src','tunefile', "template.cson"))
      content = fs.readFileSync template, 'utf-8'
      CSON.parse content, (err,obj) ->
        result = CSON.parseSync(content)

      project = getLocalProject()

      cli.info 'Writing Tunefile'
      fs.writeFileSync 'Tunefile', content, 'utf-8'
      
      cli.info 'Downloading Latest CFWheels'
      project.getWheels()

      cli.info 'Acquiring Railo Express'
      project.getRailo((path) ->
        cli.info 'Found Railo at ' + path
      )
  # #### The `install` command
  #
  # This command is used to install the modules required for the current project 
  # to function properly, according to the tunefile.
  
  program
    .command('install')
    .description("Downloads and installs Railo Express, and latest version of CFWheels")
    .action ->
      project = getLocalProject()
      if project.missingModules().length > 0
        project.installMissingModules()
      else
        cli.info 'No modules are missing.'
    
  ##### The main `wheels` command
  #
  # This command is used to actualize a whole project or specific packages within it.
  # It first checks to see if package names were specified, or `all`, which means "all packages".
  # Then, the `.actualize()` method is called on each matching package.
  
  program
    .command('*')
    .description(" Aggregate bundles from the given packages (or all)")
    .action () ->


  if !process.argv.length
      program.help()
  # This tells the `Command` object to parse the given program arguments, triggering
  # the proper action, or printing the usage.
  program.parse argv
