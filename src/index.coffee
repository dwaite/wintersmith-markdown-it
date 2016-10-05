"use strict"
async = require 'async'
fs    = require 'fs'
markdown_it = require 'markdown-it'

module.exports = ( env, callback ) ->

  class MarkdownItPage extends env.plugins.MarkdownPage
    constructor: (@filepath, @metadata, @markdown) ->

    getHtml: ( base = env.config.baseUrl ) ->
      globalOptions = env.config.markdownit
      extensions = @metadata.markdown_it or globalOptions?.extensions or "all"

      md = markdown_it()
      .use require 'markdown-it-footnote'
      .use require('./highlight'), 
        classPrefix: globalOptions?.classPrefix or "",
        autoLanguage: globalOptions?.autoLanguage or false
      .use require('./resolve_links')(this, base)
      .use require('./resolve_images')(this, base)

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
