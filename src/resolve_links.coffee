"use strict"
url   = require 'url'

module.exports = ( page, base ) ->
  (md) ->
    default_html_inline = md.renderer.rules.html_inline

    md.renderer.rules.html_inline = (tokens, idx, options, env) =>
      baseUri = page.getLocation base
  
      ### Resolve *uri* relative to *content*, resolves using
          *baseUrl* if no matching content is found. ###
      href = tokens[idx].href
      if href
        uriParts = url.parse href
        if uriParts.protocol
          # absolute uri
        else
          # search pathname in content tree relative to *content*
          nav = page.parent
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
      default_html_inline tokens, idx, options, env
