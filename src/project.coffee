# ## The *Project* class
#
# This module exports the *Project* class. A *Project* object
# is tightly coupled with, as well as initialized with, a 
# [Tunefile](tunefile.html).

# Underscore, core modules and CLI utilities are loaded.
_ = require 'underscore'
path = require 'path'
fs = require 'fs'
Downloader = require('./downloader').Downloader
env = process.env
{debug, warning, error, info, finished} = require './command'
tuneFiles = ['Tunefile', 'tunefile', 'tunefile.cson', 'Tunefile.cson']
    
# This function only tries to import the given module, and if it fails it returns
# `false` if error corresponds to a missing module error.
testModule = (mod) ->
  try
    require(mod)
  catch err
    err.message.indexOf('Cannot find module') is -1


# The Project class is initialized with a tunefile, which immidiately
# calls the `setup` instance method. There, the `configs` function
# exported from [tunefile.coffee](tunefile.html) is called with the
# given tunefile as argument, to obtain an project configuration object.
# This object is then given default values and used to initialize
# the project vendor libraries and packages. Packages are inserted as
# *array elements* in the project.
class Project
  constructor: -> @setup()
  setup: ->
    @root = path.resolve __dirname, '..'
    @file = @findConfigFile()
    @railo = @findRailo()
    try
      @configs = (require './tunefile').configs @file
      _.defaults @configs,
        root: '.'
    catch err
      if @configs?
        error 'in', @file, err.message
      else
        throw err
    
    {@root} = @configs
    
  
  # This method returns the actual name of a tunefile found in the local directory.
  findConfigFile: ->
    for file in tuneFiles
      return file if fs.existsSync "./#{file}"
    
    throw "No tunefile found"

  hasConfigFile: ->
    for file in tuneFiles
      return true if fs.existsSync "./#{file}"
    false

  # This method takes the result of the `requiredModules` below and tests each one
  # to see if the said modules are available. The method returns a list of unfound 
  # modules.
  missingModules: ->
    
  getWheels: ->

  
  findRailo:() ->
    foundPath = '';
    pathsToLook =[
      path.resolve "/tmp/Railo/"
      path.resolve "/opt/Railo/"
      path.resolve "/usr/local/Railo/"
      path.resolve "./Railo/"
    ]

    for lookPath in pathsToLook
      if fs.existsSync(lookPath)
        foundPath = lookPath  

    return foundPath
  # This method tries to install the missing modules into CFWheels Toolbelt project 
  # directory. It first caches the previous working directory before changing to
  # cfwheels root directory, so to return in the previous state.
  getRailo: (cb) ->
    @railo = @findRailo()

    if !@railo
      Downloader = require('./downloader')
      dl = new Downloader.Downloader();
      dl.set_remote_file('http://www.getrailo.org/railo/remote/download/4.0.0.013/railix/macosx/railo-4.0.0.013-railo-express-macosx.zip');
      dl.run();
    else
      cb(@railo)
  # This method is the `reset` callback invoked when any relevant change occur
  # in the project. If an error is passed, it is thrown. Otherwise, the 
  # tunefile FSWatcher is closed, and the `unwatch` method is called on each
  # packages. Finally, it deletes instance variables, contained packages and
  # re-invokes the `setup` instance method to start over.
  reset: (err) ->
    throw err if err?

exports.Project = Project