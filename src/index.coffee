"use strict"
async = require 'async'
fs    = require 'fs'
markdown_it = require 'markdown-it'

module.exports = ( env, callback ) ->

  class MarkdownItPage extends env.plugins.MarkdownPage
    constructor: (@filepath, @metadata, @markdown) ->

    getHtml: ( base = env.config.baseUrl ) ->
      plugins = env.config['markdown-it'] or {}
      for name, opts of @metadata['markdown-it'] or {}
        plugins[name] = opts

      settings = plugins['settings'] or undefined
      md = markdown_it(settings)
      highlight_settings = {}
      for name, opts of plugins
        if name == "highlight-settings"
          highlight_settings = opts
        else if name != "settings"
          env.logger.verbose("using #{name} plugin with opts #{JSON.stringify(opts)}")
          for optName, optVal of opts
            if optVal.match and optVal.match(/^function\s*\(/)
              try
                opts[optName] = eval("(#{optVal})")
              catch err
                delete opts[optName]
                env.logger.error("error evaluating #{optName} option for the #{name} markdown-it plugin: #{err}")
          md.use require(name), opts or {}
      md.use require('./highlight'),
        classPrefix: highlight_settings["class-prefix"] or '',
        autoLanguage: highlight_settings["auto-language"] or false
      md.use require('./resolve_anylink')(this, base)
      md.render @markdown

  MarkdownItPage.fromFile = ( filepath, callback ) ->
    async.waterfall [
      (callback) ->
        fs.readFile filepath.full, callback
      (buffer, callback) ->
        MarkdownItPage.extractMetadata buffer.toString(), callback
      (result, callback) =>
        {markdown, metadata} = result
        page = new this filepath, metadata, markdown
        callback null, page
    ], callback

  env.registerContentPlugin 'pages', '**/*.*(markdown|mkd|md)', MarkdownItPage

  callback( )
