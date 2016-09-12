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
    @static-dom.style.opacity = 1
    Array::slice.apply @dynamic-dom.children .map @dynamic-dom~remove-child
    @ctx = null
    if @next-items?
      @next-items = null
      @_items-received that

  get-initial-state: ->
    @children = Map!as-mutable!
    @ani-host =
      register: (id, component) !~> if component? => @children.set id, component else @children.remove id
      push-animation: (promise) !~>
        @ctx.animations-count += 1
        promise.then bound @, @ctx, (ctx, [node]) ->
          return if ctx != @ctx
          ctx.animations-count -= 1
          @animations-done ctx if ctx.animations-count < 1
    items: null

  component-did-mount: !->
    if @next-items?
      @next-items = null
      @_items-received that

  _items-received: (items) ->
    return if items == (old-items = @state.items)
    old-items ?= List!
    if @ctx? or not @is-mounted!
      console.log 'scheduling'
      @next-items = items
    else
      [nkeys, okeys] = [items, old-items].map ((.map (.get \id)) >> Set)
      @ctx = {} <<< do
        added: (added = nkeys.subtract okeys)
        removed: (removed = okeys.subtract nkeys)
        moved: (nkeys.subtract added .subtract removed)
        animations-count: 0
        before: !~>
          {removed, moved, added} = @ctx

          Array::slice.apply (@dynamic-dom?children ? []) .for-each (c) -> c.parent-node?remove-child c

          @static-dom.style.opacity = 0
          @clones = Map!as-mutable!
          @children.for-each (c, id) ~>
            @clones.set id, (node = c.clone-dom!)
            node
              @dynamic-dom.append-child ..
              old-frame = c.get-frame!
              ..style <<< {[k, "#{old-frame[i]}px"] for k, i in <[left top width height]>} <<< do
                position: \absolute

          # @origins = moved.union removed .map (~> [it, @children.get it .get-frame?!]) |> Map
          @remove-animations = removed.map ~> (@children.get it)?make-remove-animation? (@clones.get it)
        after: !~>
          try
            {added, moved, removed} = @ctx

            @move-animations = moved.map ~> @children.get it .make-move-animation? (@clones.get it)
            added.for-each (id) ~>
              c = @children.get id
              @clones.set id, (node = c.clone-dom!)
              node
                @dynamic-dom.append-child ..
                old-frame = c.get-frame!
                ..style <<< {[k, "#{old-frame[i]}px"] for k, i in <[left top width height]>} <<< do
                  position: \absolute
            added.map (~> @children.get it .make-add-animation? (@clones.get it))
          finally
            @animations-done @ctx if @ctx.animations-count < 1
      @set-state items:items

  component-will-mount: ->
    @_items-received @props.items

  component-will-receive-props: (np) ->
    if np.items != @props.items != @next-items
      @_items-received np.items

  component-will-update: ->
    @ctx?before?!
    @ctx?before = null
  component-did-update: ->
    @ctx?after?!
    @ctx?after = null

  render: ->
    {props:{component}, ani-host} = @
    {items} = @state

    div className:\ani-list,
      div do
        className:\static
        ref:(!~> @static-dom = it)
        items?map (i) ~>
          id = i.get \id
          create-element do
            component
            key:id
            item:i
            ani-host:ani-host
      div className:\dynamic, ref: ~> @dynamic-dom = it
