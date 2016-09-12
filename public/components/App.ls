require! \fs
{concat-map, drop, filter, find, fold, group-by, id, keys, last, map, Obj, obj-to-pairs, pairs-to-obj,
reject, reverse, Str, sort-by, take, unique,  unique-by, values, zip-with} = require \prelude-ls
{partition-string} = require \prelude-extension
{create-factory, DOM:{a, button, div, form, h1, h2, img, input, li, ol, option, span, ul}}:React = require \react
{render:dom-render} = require \react-dom
require! \react-tools
Immutable = require \immutable
{Anilist, AniItemMixin} = require \index.ls
_ = require \underscore
sodom = require \sodom.ls
Velocity = require \velocity-animate

const test-anim-duration = 1000

AniTestItem = React.createClass do
  mixins: [AniItemMixin]

  should-component-update: (np) -> @props.item != np.item

  make-add-animation: (node) ->
    node.style.opacity = 0
    Velocity node, {opacity:1}, do
      duration: test-anim-duration

  make-move-animation: (node) ->
    new-frame = @get-frame!
    old-frame = <[left top width height]>.map ((node.style.) >> (parseInt<|))
    return if (new-frame.every (v, idx) -> old-frame[idx] == v)

    Velocity node, {[k, new-frame[i]] for k, i in <[left top width height]>}, do
      duration: test-anim-duration

  make-remove-animation: (node) ->
    node.style.opacity = 1
    Velocity node, {opacity:0}, do
      duration: test-anim-duration

  get-frame: ->
    node = sodom @refs.root
    [(.left!), (.top!), (.width!), (.height!)].map (node|>)

  clone-dom: -> @refs.root.clone-node true

  render: ->
    div ref:\root, @props.item.get \title

Immutable.List::shuffle = ->
  sz = @size
  @with-mutations (list) ->
    for i in [0 til sz]
      j = Math.random! * sz |> Math.floor |> Math.min _, (sz - 1)
      a = list.get i
      list
      .set i, list.get j
      .set j, a
    list

App = React.createClass do
  displayName: 'App'
  get-initial-state: ->
    items: Immutable.List!

  component-will-mount: !->
    @_id = 100

    shuffle = -> it.shuffle!
    swap1 = ~>
      it.with-mutations (items) ->
        t = items.get 3
        items.set 3, (items.get 6) .set 6, t
    add-and-remove = ~>
      it.remove 0 .concat [Immutable.fromJS do
        id: @_id
        title: @_id++
      ]
    add1 = ~>
      it.concat [Immutable.fromJS do
        id: @_id
        title: @_id++
      ]

    <~! @set-state items:Immutable.fromJS ([0 til 10].map -> {id:it, title:"#{it}"})
    do testing = !~>
      <~! setTimeout _, 1000
      <~! @set-state items:((shuffle) @state.items)
      console.log 'count:', @state.items.size
      testing!

  render: ->
    React.createElement Anilist, component:AniTestItem, items:@state.items

window.onload = ->
  dom-render do
    React.createElement App, null
    document.getElementById 'app'
