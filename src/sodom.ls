module.exports =
  top: -> it.offset-top ? it.client-top
  left: -> it.offset-left ? it.client-left
  height: -> it.offset-height ? it.client-height
  width: -> it.offset-width ? it.client-width
  bottom: -> (@top it) + (@height it)
  right: -> (@left it) + (@width it)
  clone: -> it.clone-node true
