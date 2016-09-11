require! \fs
{concat-map, drop, filter, find, fold, group-by, id, keys, last, map, Obj, obj-to-pairs, pairs-to-obj,
reject, reverse, Str, sort-by, take, unique,  unique-by, values, zip-with} = require \prelude-ls
{partition-string} = require \prelude-extension
{create-factory, DOM:{a, button, div, form, h1, h2, img, input, li, ol, option, span, ul}}:React = require \react
{render} = require \react-dom
require! \react-tools
# {} = require \index.ls
_ = require \underscore

App = React.create-class do
    display-name: \App
    render: ->
      div null, 'TEXT'

window.onload = !->
  render do
    React.create-element App
    document.get-element-by-id \app
