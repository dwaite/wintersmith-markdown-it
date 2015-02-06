async = require 'async'
fs    = require 'fs'
hljs  = require 'highlight.js'
markdown_it = require 'markdown-it'
url   = require 'url'

module.exports = ( env, callback ) ->

  class MarkdownItPage extends env.plugins.MarkdownPage
    constructor: (@filepath, @metadata, @markdown) ->
    getHtml: ( base = env.config.baseUrl ) ->
      globalOptions = env.config.markdownit
      extensions = @metadata.markdown_it or globalOptions?.extensions or "all"
      if globalOptions?.hljsClassPrefix?
        hljs.configure classPrefix: globalOptions.hljsClassPrefix

      md = markdown_it
        highlight: (str, lang) ->
          if lang and hljs.getLanguage lang
            try
              return hljs.highlight(lang, str).value;
          try
            return hljs.highlightAuto(str).value;
          # use external default escaping
          return ''
      .use require 'markdown-it-footnote'

      default_link_open = md.renderer.rules.link_open
      md.renderer.rules.link_open = (tokens, idx, options, env) =>
        baseUri = this.getLocation base
    
        ### Resolve *uri* relative to *content*, resolves using
            *baseUrl* if no matching content is found. ###
        href = tokens[idx].href
        if href
          uriParts = url.parse href
          if uriParts.protocol
            # absolute uri
          else
            # search pathname in content tree relative to *content*
            nav = this.parent
            path = uriParts.pathname?.split('/') or []
            while path.length and nav?
              part = path.shift()
              if part == ''
                # uri begins with / go to contents root
                nav = nav.parent while nav.parent
              else if part == '..'
                nav = nav.parent
              else
                nav = nav[part]
            if nav?.getUrl?
              href = nav.getUrl() + [uriParts.hash]
            tokens[idx].href = url.resolve baseUri, href
        default_link_open tokens, idx, options, env

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
