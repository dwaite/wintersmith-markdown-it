"use strict"
hljs  = require 'highlight.js'

# Module to support highlight.js
#
# two options:
# classPrefix - a common prefix for the class elements used for css styling
#               the default is 'hljs-'
# autoLanguage - if language is not specified or formatting using the specified
#                language fails, attempt to have highlight.js automatically
#                stylize the content. This will in most scenarios result in
#                any other highlighting behavior to not be triggered. The
#                default is false
module.exports = ( md, opts ) ->
  # unfortunately, the highlight instance is a singleton so this is perhaps
  # more global than we would like
  if opts?.classPrefix?
    hljs.configure classPrefix: opts.classPrefix
  autoLanguage = opts?.autoLanguage
  
  # if there is a highlighter already specified we'll chain into it
  # in the cases where we don't know what to do
  existing_highlight = md.options.highlight
  
  md.options.highlight = (str, lang) ->
    if lang and hljs.getLanguage lang
      try
        return hljs.highlight(lang, str).value;
    if autoLanguage
      try
        return hljs.highlightAuto(str).value;

    if existing_highlight
      return existing_highlight str, lang
    return ''
