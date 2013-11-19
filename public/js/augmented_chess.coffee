# CoffeeScript
(($) ->
  test = ->
    style_cells('#pieces .7 td', 'black pawn')
    style_cells('#pieces .2 td', 'white pawn')

  $(document).ready ->
    style_cells('#board tr:even td:odd', 'dark')
    style_cells('#board tr:even td:even', 'light')
    style_cells('#board tr:odd td:even', 'dark')
    style_cells('#board tr:odd td:odd', 'light')
    test()
    resize()
    resize()

  $(window).resize ->
    resize()

  resize = ->
    cells = $('td')
    $(cell).height($(cell).width()) for cell in cells

  # s = the jquery selector
  # c = the class to add
  style_cells = (s, c) ->
    cells = $(s)
    $(cell).addClass(c) for cell in cells



) jQuery