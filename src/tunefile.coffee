# This module is used internally to parse a Tunefile at the
# root folder of a given project. It exports a single function :
#
# * `configs(file)`
#
#   This function takes the path to a Tunefile and returns a
#   configuration object that can be used to initialize a 
#   `Project` object.

# Some essential core modules are loaded, as well as coffee-script
# since a Tunefile is written using this language.
vm = require("vm")
pathUtil = require('path')
_ = require('underscore')

CSON = require('cson')
# wheels classes (and utilities) are imported
{debug} = require './command'
wheels = require './index'

# A utility function used to initialize a V8 Context
# to encapsulate the configuration included in the
# Tunefile and all the DSL functions.
newContext = () ->
  ctx = {}
 
  # Define DSL functions to specify properties of the project
  ctx.root = (newRoot) -> prj.root = newRoot

  # Return a V8 context, using the container above as
  # a seed.
  vm.createContext ctx


# This is the exported function, which takes a path to a Tunefile 
# as argument and returns a configuration object containing all the 
# packages. It uses Coffee-script's `eval` function to execute the file 
# content, using the `newContext` function above to get a context 
# appropriate for the DSL, and setting the filename to ease debugging.
# Once the file was executed, `ctx.project` 
# holds the set of configurations for a project object, which is returned.

@configs = configs = (file) ->
  CSON.parseFile file,(err,obj) -> 
    sandbox: ctx = newContext()
    filename: file
    return ctx.project
