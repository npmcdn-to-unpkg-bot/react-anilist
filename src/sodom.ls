module.exports = do ->
  class SodomNode
    (@node) ->
    top: -> @node.offset-top ? @node.client-top
    left: -> @node.offset-left ? @node.client-left
    height: -> @node.offset-height ? @node.client-height
    width: -> @node.offset-width ? @node.client-width
    bottom: -> @top! + @height!
    right: -> @left! + @width!
    clone: -> @node.clone-node true
    clear: -> Array::slice.apply @node.children .map @node~remove-child

  (node) ->
    new SodomNode node if node?
