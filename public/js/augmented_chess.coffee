# CoffeeScript
(($) ->
  $(document).ready ->
    resize()
  $(window).resize ->
    resize()

  resize = ->
    cells = $('td')
    $(cell).height($(cell).width()) for cell in cells
) jQuery