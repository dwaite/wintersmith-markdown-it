"use strict"
url   = require 'url'

module.exports = ( page, base ) ->
  (md) ->
    md.core.ruler.after 'inline', 'replace-link', (state) ->
      baseUri = page.getLocation base

      for blocktoken in state.tokens
        if blocktoken.type == 'inline' and blocktoken.children
          for token in blocktoken.children
            href = null
            attrName = 'href'
            if token.type == 'link_open'
              href = token.attrGet attrName
            else if token.type == 'image'
              attrName = 'src'
              href = token.attrGet attrName

            ### Resolve *uri* relative to *content*, resolves using
                *baseUrl* if no matching content is found. ###
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
                token.attrSet attrName, url.resolve(baseUri, href)
