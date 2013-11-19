# CoffeeScript
(($) ->
  $(document).ready ->
    cells = $('td')
    $(cell).height($(cell).width()) for cell in cells
) jQuery