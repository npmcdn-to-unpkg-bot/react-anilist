{create-factory, create-element, DOM:{a, button, div, form, h1, h2, img, input, li, ol, option, span, ul}}:React = require \react
{render:dom-render} = require \react-dom
{Map, Set, List, fromJS:immutable} = require \immutable
sodom = require \./sodom

# just functional-style .bind()-method
# to use like
#   f = bound @, a, b, (a, b) -> @method a, b
bound = ->
  [...args, fn] = &
  Function.bind.apply fn, args

module.exports = React.create-class do
  display-name: \AniList

  animations-done: (ctx) ->
    @static-dom.node.style.opacity = 1
    @dynamic-dom.clear!
    @ctx = null
    if @next-items?
      @next-items = null
      @_items-received that

  get-initial-state: ->
    @children = Map!as-mutable!
    items: null

  component-did-mount: !->
    if @next-items?
      @next-items = null
      @_items-received that

  prepare-node: (c, id) ->
    node = c.clone-dom!
    old-frame = c.get-frame!

    @ctx.clones.set id, node
    node.style <<< {[k, "#{old-frame[i]}px"] for k, i in <[left top width height]>} <<< do
      position: \absolute

    @dynamic-dom.node.append-child node
    node

  _items-received: (items) ->
    return if items == (old-items = @state.items)
    old-items ?= List!
    if @ctx? or not @is-mounted!
      @next-items = items
    else
      [nkeys, okeys] = [items, old-items].map ((.map (.get \id)) >> Set)
      @ctx = {} <<< do
        added: (added = nkeys.subtract okeys)
        removed: (removed = okeys.subtract nkeys)
        moved: (nkeys.subtract added .subtract removed)
        animations-count: 0
        clones: Map!as-mutable!

        before: !~>
          @dynamic-dom?clear!
          @static-dom.node.style.opacity = 0

          {removed, moved, added} = @ctx
          @children.for-each (c, id) ~> @prepare-node c, id
          @ctx.animations = removed.map ~> @children.get it .make-remove-animation? (@ctx.clones.get it)

        after: !~>
          {added, moved, removed} = @ctx

          added.for-each (id) ~> @prepare-node (@children.get id), id

          @ctx
            ..animations = ..animations
            .concat moved.map ~> @children.get it .make-move-animation? (@ctx.clones.get it)
            .concat added.map ~> @children.get it .make-add-animation? (@ctx.clones.get it)
            .filter (?)

            ..animations-count = ..animations.size
            ..animations.for-each (promise) !~>
              promise.then bound @, @ctx, (ctx) !->
                return if ctx != @ctx
                ctx.animations-count -= 1
                @animations-done ctx if ctx.animations-count < 1

            @animations-done .. if not ..animations.size
      @set-state items:items

  component-will-mount: -> @_items-received @props.items
  component-will-receive-props: (np) !-> @_items-received np.items if np.items != @props.items != @next-items

  component-will-update: !-> @ctx?before &&= (@ctx.before!; null)
  component-did-update: !-> @ctx?after &&= (@ctx.after!; null)

  render: ->
    {props:{component}} = @
    {items} = @state

    div class-name:\ani-list,
      div do
        class-name:\static
        ref: !~> @static-dom = sodom it
        items?map (i) ~>
          id = i.get \id
          create-element do
            component
            key:id
            item:i
            ref: bound @, id, (id, component) !-> if component? => @children.set id, component else @children.remove id
      div className:\dynamic, ref: ~> @dynamic-dom = sodom it
