sodom = require \./sodom

module.exports = do
  component-did-mount: ->
    @props.ani-host.register (@props.item.get \id), @

  component-will-unmount: ->
    @props.ani-host.register (@props.item.get \id), null

  get-dynamic: ->
    return d if (d = @dynamic)?parent-node?
    @dynamic = do ~>
      @clone-dom!
        @props.ani-host.add-dynamic ..
