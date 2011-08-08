###
  Allow collapsing/expanding comments on Hacker News story pages.
  Loosely based on https://github.com/niyazpk/Collapsible-comments-for-Hacker-News
###

# Ignore non-story pages.
return unless window.location.pathname is '/item'

$('''<style>
  .comment.collapsed a[href^=vote] {
    visibility: hidden;
  }
  .comment.collapsed td.default > span, .comment.collapsed td.default > p {
    display: none;
  }
  .comment .fold {
    cursor: pointer;
    font-size: 18px;
    line-height: 8px;
    margin-left: 7px;
    position: relative;
    top: 1px;
  }
</style>''').appendTo('head')

comments = $('center table:first tr:eq(3) table:eq(1) > tbody > tr')
collapseText = '⊖'
expandText = '⊕'

# HN uses spacer images to indicate comment nesting, though the DOM structure
# remains linear (one table row per comment). This method finds the deeper
# "children" of a given comment and applies a given function to each one.
jQuery.fn.deeperSiblings = (fn, skipCollapsedChildren = false) ->
  parentDepth = @find('img[height=1]').attr('width')
  innerDepth = null
  @nextAll().each ->
    child = $(this)
    depth = child.find('img[height=1]').attr('width')
    if innerDepth?
      # If this element is deeper than the last collapsed child seen, skip it;
      # otherwise, there are no further children of the collapsed child.
      if depth > innerDepth then return else innerDepth = null
    if skipCollapsedChildren and child.hasClass('collapsed')
      # Skip all deeper children.
      innerDepth = depth
    # So long as this child is deeper than the parent, apply the function.
    # Otherwise, there are no further children, so break out of .each().
    if depth > parentDepth then fn.apply(child) else return false

comments.addClass('comment')
  .find('.comhead').append($('<a class=fold>').text(collapseText))

$('a.fold').click ->
  comment = $(this).closest('tr.comment').toggleClass('collapsed')
  if comment.hasClass('collapsed')
    $(this).text(expandText)
    comment.deeperSiblings(jQuery.fn.hide)
  else
    $(this).text(collapseText)
    comment.deeperSiblings(jQuery.fn.show, true)
