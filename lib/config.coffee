Promise = require 'bluebird'
path = require 'path'
fs = require 'fs-extra'
CSON = require 'cson'
{log, warn, error} = require './utils'

{ROOT, EXROOT} = global

config = {}
configCache = {}
defaultConfigPath = path.join(ROOT, 'config.cson')
configPath = path.join(EXROOT, 'config.cson')

# Read saved config
try
  fs.accessSync defaultConfigPath, fs.R_OK | fs.W_OK
  config = CSON.parseCSONFile defaultConfigPath
catch e
  warn e

# Read user config
try
  fs.accessSync configPath, fs.R_OK | fs.W_OK
  config = CSON.parseCSONFile configPath
catch e
  warn e

module.exports =
  get: (path, value) ->
    return configCache[path] if configCache[path]?
    path = path.split('.').filter (p) -> p != ''
    cur = config
    for p in path
      cur = cur?[p]
    configCache[path] = if cur? then cur else value
  set: (path, value) ->
    delete configCache[path] if configCache[path]?
    path = path.split('.').filter (p) -> p != ''
    cur = config
    len = path.length
    for p, i in path
      if i != len - 1
        cur[p] = {} if typeof cur[p] != 'object'
        cur = cur[p]
      else
        cur[p] = value
    # Save to file
    try
      fs.writeFileSync configPath, CSON.stringify(config, null, 2)
    catch e
      warn e
