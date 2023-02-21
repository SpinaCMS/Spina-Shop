window.App = {}

class App.InfiniteScroll

  @init: (link) ->
    $("section#main").off('scroll.infiniteScroll')

    $link = $(link)
    if (url = $link.find('a').attr('href'))
      $("section#main").on 'scroll.infiniteScroll', => @loadNextPage($link)
      $("section#main").scroll()

  @loadNextPage: ($link) ->
    href = $link.find('a').attr('href')
    link = $link.find('a')
    top = $link[0].getBoundingClientRect().top
    
    if (top < window.innerHeight + 500)
      $("section#main").off('scroll.infiniteScroll')
      link.remove()
      $.getScript(href)

$.fn.infiniteScroll = () ->
  App.InfiniteScroll.init(this)

$(document).on 'turbo:before-render', ->
  $("section#main").off('scroll.infiniteScroll')
