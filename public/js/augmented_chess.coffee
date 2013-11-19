# CoffeeScript
(($) ->
  test = ->
    format_cells('#colors .row1 td', 'white3')
    format_cells('#colors .row2 td', 'white2')
    format_cells('#colors .row3 td', 'white1')
    format_cells('#colors .row6 td', 'black1')
    format_cells('#colors .row7 td', 'black2')
    format_cells('#colors .row8 td', 'black3')

  $(document).ready ->
    resize()
    format_cells('#board tr:even td:odd', 'dark')
    format_cells('#board tr:even td:even', 'light')
    format_cells('#board tr:odd td:even', 'dark')
    format_cells('#board tr:odd td:odd', 'light')
    test()
  $(window).resize ->
    resize()

  resize = ->
    cells = $('td')
    $(cell).height($(cell).width()) for cell in cells

  format_cells = (s, c) ->
    cells = $(s)
    $(cell).addClass(c) for cell in cells

) jQuery