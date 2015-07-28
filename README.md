[Wintersmith](http://wintersmith.io) plugin for 
[Markdown-it](https://github.com/markdown-it/markdown-it).

## Usage

Add this plugin to your Wintersmith config.json file.

```json
{
  "locals": {
    "title": "Bare minimum wintersmith site"
  },
  "plugins": [
    "../node_modules/wintersmith-markdown-it/"
  ]
}
```

## Markdown-It Plugins

To use a markdown-it plugin, add it to your package.json as a dependency. Then you must configure the plugin for use.

There are two places to declare markdown-it plugins: in your Wintersmith config.json, or in the metadata for a Wintersmith
markdown file. Configurations in the latter take precedence. Put the plugins under the `markdown-it` property. The options for a
plugin can also be specified. If an option value matches `/^function\s*\(/` it will be eval'd.

Here's what plugin configuration in config.json looks like:

```json
{
  "locals": {
    "title": "Bare minimum wintersmith site"
  },
  "plugins": [
    "../node_modules/wintersmith-markdown-it/"
  ],
  "markdown-it": {
    "markdown-it-footnote": {},
    "markdown-it-headinganchor": {
      "anchorClass": "my-class-name",
      "addHeadingID": true,
      "addHeadingAnchor": true,
      "slugify": "function (str, md) { return str.replace(/[^a-z0-9]/ig, '-'); }"
    }
  }
}
```

And here's what plugin configuration in a markdown file looks like:

```markdown
---
title: Lorem
template: index.jade
markdown-it:
  markdown-it-footnote:
  markdown-it-headinganchor:
     anchorClass: my-class-name,
     addHeadingID: true,
     addHeadingAnchor: true,
     slugify: function (str, md) { return str.replace(/[^a-z0-9]/ig, '-'); }
---

# Title

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 

```

