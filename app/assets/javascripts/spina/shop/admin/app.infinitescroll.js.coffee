window.App = {}

class App.InfiniteScroll

  @init: (link) ->
    $(window).off('scroll.infiniteScroll')

    $link = $(link)
    if (url = $link.find('a').attr('href'))
      $(window).on 'scroll.infiniteScroll', => @loadNextPage($link)
      $(window).scroll()

  @loadNextPage: ($link) ->
    if ($(window).scrollTop() > $link.offset().top - $(window).height() - 500)
      $(window).off('scroll.infiniteScroll')
      $link.find('a').attr('disabled', true)
      $.getScript($link.find('a').attr('href'))

$.fn.infiniteScroll = () ->
  App.InfiniteScroll.init(this)

$(document).on 'turbo:before-render', ->
  $(window).off('scroll.infiniteScroll')
