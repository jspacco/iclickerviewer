#
# shared coffeescript functions
# https://stackoverflow.com/questions/20561740/shared-js-coffee-in-rails
#
class Shared
  # --------------------------------
  # setup modal images
  #
  # To set up a modal image:
  #
  # clickable image(s) to be expanded should have class="myImg"
  # div tag surrounding the modal should have id="myModal"
  # img tag of the modal image (the one that will be replaced with whatever is
  #   clicked) should have id="img01"
  #
  @setup_modal_image: () ->
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
root = exports ? this
root.Shared = Shared
