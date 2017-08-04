# TODO factor modal images into a JS helper function
# https://stackoverflow.com/questions/20561740/shared-js-coffee-in-rails
root = exports ? this
root.load_page_handler = ->
  jQuery ->
    modal = $("#myModal")
    modal.on "click", ->
      modal.css('display', 'none')
      return 0
    # Get the image and insert it inside the modal
    modalImg = $("#img01")
    $('.myImg').click( ->
      # Basically, if an image with class myImg is clicked,
      # set it to the src of the modal image and display it.
      modal.css('display', 'block')
      modalImg.attr('src', this.src)
      return 0
    )
  return 0
