# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this
root.question_pair_handler =(question_index, question_pair, old_question_pair) ->
  # console.log("question_index #{question_index} question_pair #{question_pair} old_question_pair #{old_question_pair}")
  # Remember that the question_types are:
  # 0: unknown
  # 1: quiz
  # 2: single
  # 3: paired
  # 4: non-MCQ
  # 5: error
  jQuery ->
    selected_type = "select.question_type_#{question_index}"
    paired_type = "select.question_type_#{question_pair}"
    old_type = "select.question_type_#{old_question_pair}"
    selected_pair = "select.question_pair_#{question_pair}"
    old_pair = "select.question_pair_#{old_question_pair}"
    if old_question_pair == ''
      if question_pair != ''
        # old_question_pair == '' and question_pair != '' then update question_pair
        # console.log('regular update')
        $(selected_type).val('3')
        $(paired_type).val('3')
        $(selected_pair).val("#{question_index}")
      else
        # if old_question_pair == '' and question_pair == '' then something went wrong
        alert('probably an error')
    else
      # if old_question_pair != '' then unset old_question_pair
      # console.log("unset #{old_question_pair}")
      $(selected_type).val('0')
      $(old_type).val('0')
      $(old_pair).val('')
      if question_pair != ''
        # if question_pair == '' then update
        # console.log('update after unset')
        $(selected_type).val('3')
        $(paired_type).val('3')
        $(selected_pair).val("#{question_index}")
  return 0

#
# Dynamically change the image preview at the top
#
root.dynamic_image_handler =(course_hash, first_load) ->
  jQuery ->
    dynamic_course = $("#dynamic_course")
    dynamic_class_period = $("#dynamic_class_period")
    dynamic_question = $("#dynamic_question")

    dynamic_course_selected = dynamic_course.val()
    dynamic_class_period_selected = dynamic_class_period.val()
    dynamic_question_selected = dynamic_question.val()

    # Fill out list of courses only when the page first loads
    #   and the global vars remembering the previous selections are empty
    if first_load
      dynamic_course.empty()
      for course in (x for own x of course_hash).sort()
        dynamic_course.append($('<option>', {
          value: course,
          text: course
        }));
      # If we refill, just pick the first option
      dynamic_course_selected = $("#dynamic_course option:first").val()
    dynamic_course.val(dynamic_course_selected)

    # Refill only when the course changed, or on first load
    if first_load or old_dynamic_course_selected != dynamic_course_selected
      dynamic_class_period.empty()
      for class_period in (x for own x of course_hash[dynamic_course_selected]).sort()
        dynamic_class_period.append($('<option>', {
          value: class_period,
          text: class_period
        }));
      # If we refill, just pick the first option
      dynamic_class_period_selected = $("#dynamic_class_period option:first").val()
    # Select the selected class period
    dynamic_class_period.val(dynamic_class_period_selected)

    # Refill when course changed, or when class period changed, or on first load
    if first_load or
    old_dynamic_course_selected != dynamic_course_selected or
    old_dynamic_class_period_selected != dynamic_class_period_selected
      dynamic_question.empty()
      for question_index in (k for own k of course_hash[dynamic_course_selected][dynamic_class_period_selected]).sort()
        question_id = course_hash[dynamic_course_selected][dynamic_class_period_selected][question_index]
        dynamic_question.append($('<option>', {
          value: question_index,
          text: "#{question_index} (#{question_id})"
        }));
      dynamic_question_selected = $("#dynamic_question option:first").val()
    dynamic_question.val(dynamic_question_selected)

    # console.log "course: #{dynamic_course_selected}, class: #{dynamic_class_period_selected}, question: #{dynamic_question_selected}"
    question_id = course_hash[dynamic_course_selected][dynamic_class_period_selected][dynamic_question_selected]
    root.question_id = question_id
    addr = "https://s3.amazonaws.com/iclickerviewer/#{dynamic_course_selected}/Images/#{dynamic_class_period_selected}_Q#{dynamic_question_selected}.jpg"
    # console.log addr
    $("#dynamic_image").attr('src', addr)

    # TODO: put these in hidden inputs so that they survive page reloads
    root.old_dynamic_course_selected = dynamic_course_selected
    root.old_dynamic_class_period_selected = dynamic_class_period_selected
    root.old_dynamic_question_selected = dynamic_question_selected

    # HACK: adding modal image click handlers here because they need to be
    # loaded at page load time
    if first_load
      modal = $("#myModal")
      modal.on "click", ->
        modal.css('display', 'none')
        return 0
      # Get the image and insert it inside the modal
      modalImg = $("#img01")
      $('.myImg').click( ->
        modal.css('display', 'block')
        newSrc = this.src
        modalImg.attr('src', newSrc)
        return 0
      )
  return 0

root.use_quick_preview =(question_id) ->
  $("#questions_#{question_id}_matching_questions").val(root.question_id)
  return 0
