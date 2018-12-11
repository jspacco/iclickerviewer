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

    old_dynamic_course_selected = $("#old_dynamic_course_selected").val()
    old_dynamic_class_period_selected = $("#old_dynamic_class_period_selected").val()
    old_dynamic_question_selected = $("#old_dynamic_question_selected").val()

    course_changed = dynamic_course_selected != old_dynamic_course_selected
    class_period_changed = dynamic_class_period_selected != old_dynamic_class_period_selected
    question_changed = dynamic_question_selected != old_dynamic_question_selected
    ###
    console.log "dynamic_course_selected: #{dynamic_course_selected}"
    console.log "dynamic_class_period_selected: #{dynamic_class_period_selected}"
    console.log "dynamic_question_selected: #{dynamic_question_selected}"
    console.log "old_dynamic_course_selected: #{old_dynamic_course_selected}"
    console.log "old_dynamic_class_period_selected: #{old_dynamic_class_period_selected}"
    console.log "old_dynamic_question_selected: #{old_dynamic_question_selected}"
    console.log "course_changed: #{course_changed}"
    console.log "class_period_changed: #{class_period_changed}"
    console.log "question_changed: #{question_changed}"
    ###
    # Fill out list of courses only when the page first loads
    #   and the global vars remembering the previous selections are empty
    if first_load
      dynamic_course.empty()
      for course in (x for own x of course_hash).sort()
        dynamic_course.append($('<option>', {
          value: course,
          text: course
        }));
      # If we refill the list of courses, just pick the first option
      if old_dynamic_course_selected != ''
        # console.log "use old dynamic course: #{old_dynamic_course_selected}"
        dynamic_course_selected = old_dynamic_course_selected
      else
        # console.log "use first dynamic course: #{dynamic_course_selected}"
        dynamic_course_selected = $("#dynamic_course option:first").val()
    dynamic_course.val(dynamic_course_selected)

    # Refill only when the course changed, or on first load
    if first_load or course_changed
      dynamic_class_period.empty()
      for class_period in (x for own x of course_hash[dynamic_course_selected]).sort()
        dynamic_class_period.append($('<option>', {
          value: class_period,
          text: class_period
        }));
      dynamic_class_period_selected = $("#dynamic_class_period option:first").val()
    # If loading the page and a previous class period selection exists, use it
    if first_load and old_dynamic_class_period_selected != ''
      # console.log "use old dynamic class period: #{old_dynamic_class_period_selected}"
      dynamic_class_period_selected = old_dynamic_class_period_selected
    dynamic_class_period.val(dynamic_class_period_selected)

    # Refill when course changed, or when class period changed, or on first load
    if first_load or
    course_changed or
    class_period_changed
      dynamic_question.empty()
      for question_index in (k for own k of course_hash[dynamic_course_selected][dynamic_class_period_selected]).sort(compare =(a,b) -> return +a - +b)
        question_id = course_hash[dynamic_course_selected][dynamic_class_period_selected][question_index]
        dynamic_question.append($('<option>', {
          value: question_index,
          text: "#{question_index} (#{question_id})"
        }));
      dynamic_question_selected = $("#dynamic_question option:first").val()
    # If loading the page and a previous question selection exists, use it
    if first_load and old_dynamic_question_selected != ''
      dynamic_question_selected = old_dynamic_question_selected
    dynamic_question.val(dynamic_question_selected)

    # console.log "course: #{dynamic_course_selected}, class: #{dynamic_class_period_selected}, question: #{dynamic_question_selected}"
    # putting questio_id into the DOM as a global so that it can be used by use_quick_preview
    question_id = course_hash[dynamic_course_selected][dynamic_class_period_selected][dynamic_question_selected]
    root.question_id = question_id
    addr = "https://s3.amazonaws.com/iclickerviewer/#{dynamic_course_selected}/Images/#{dynamic_class_period_selected}_Q#{dynamic_question_selected}.jpg"
    # console.log addr
    $("#dynamic_image").attr('src', addr)

    $("#old_dynamic_course_selected").val(dynamic_course_selected)
    $("#old_dynamic_class_period_selected").val(dynamic_class_period_selected)
    $("#old_dynamic_question_selected").val(dynamic_question_selected)
  return 0

#
# Copy the question_id (db primary key) from the quick preview image
#   to the text input to signify matching questions.
#
root.use_quick_preview =(question_id) ->
  $("#questions_#{question_id}_matching_questions").val(root.question_id)
  $("#questions_#{question_id}_match_type_identical").prop('checked', true)
  return 0

#
# Button handler for the "NEXT CLASS" button.
# Redirect to the next class period, but after setting the currently selected
#   quick preview image options to get parameters, so that the page for
#   the next class period loads with the same quick preview image selected.
#
root.next_class_button_handler = (url) ->
  course = $("#dynamic_course").val()
  class_period = $("#dynamic_class_period").val()
  question = $("#dynamic_question").val()
  addr = "#{url}?old_dynamic_course_selected=#{course}"+
    "&old_dynamic_class_period_selected=#{class_period}"+
    "&old_dynamic_question_selected=#{question}"
  window.location.href = addr

#
# show/hide image match comparison
#selected_compare_img
root.compare_images =(imgsrc) ->
  if $('.compare_images').is(':visible')
    $('.compare_images').hide()
    $('.compare_images').css('z-index', -1)
  else
    $('#selected_compare_image').attr('src', imgsrc)
    $('#preview_compare_image').attr('src', $('#dynamic_image').prop('src'))
    $('.compare_images').show()
    $('.compare_images').css('z-index', 3)

#
# close the compare images panel
#
root.close_compare_images =() ->
  $('.compare_images').hide()
  $('.compare_images').css('z-index', -1)

#
# show/hide the quick preview
#
root.toggle_quick_preview =() ->
  if $('.topdiv').is(':visible')
    $('.topdiv').hide()
    $('.topdiv').css('z-index', -1)
  else
    $('.topdiv').show()
    $('.topdiv').css('z-index', 2)

#
# helper function
#
html_id =(id, ch) ->
  return "questions_#{id}_correct_#{ch}"

edit_matching_id =(qid, mqid, button) ->
  return "questions_#{qid}_edit_matching_questions_#{mqid}_#{button}"

edit_delete_id =(qid,mqid)->
  return "questions_#{qid}_delete_matching_questions__#{mqid}"

edit_match_option_id =(qid, mqid, type)->
  return "questions_#{qid}_set_changed_#{type}_#{mqid}"

new_matching_id =(qid, button)->
  #console.log("#{qid} is qid from inside new_matching_id. button is #{button}")
  return "questions_#{qid}_match_type_#{button}"

new_match_option_id =(qid,type)->
  return "questions_#{qid}_set_#{type}"


#
# When we double-click a correctness checkbox, select
# all of the ones we didn't click.
#
# This is used for "A or not A" questions, which are sort
# of like "true/false" questions, except instead of A/B
# it's "A for true, not A for false"
#
root.select_all_inverse =(id, clicked_letter) ->
  # labels and checkboxes are of the form:
  # questions_12345_correct_a
  # We are given the id, which is 12345 in the example above,
  # and the letter of the id, which is 'a' in the example above.
  # Using this information and JQuery,
  # check all the checkboxes except the one that was
  # double-clicked, which will be left unchecked.
  clicked = html_id(id, clicked_letter)
  for letter in ['a', 'b', 'c', 'd', 'e']
    current = html_id(id, letter)
    if clicked == current
      $("##{current}").prop("checked", false)
    else
      $("##{current}").prop("checked", true)
  return 0

#
# reset the correctness checkboxes that match the given html id
#
root.reset_correct_checkboxes =(id) ->
  for letter in ['a', 'b', 'c', 'd', 'e']
    id_tag = html_id(id, letter)
    $("##{id_tag}").prop("checked", false)
  return 0

#
# when you click identical or modified, uncheck any modified+ categories
# when you click a modified+ category, automatically select modified+
#
root.matching_logic =(qid, mqid, clicked_box) ->
  delete_id = edit_delete_id(qid, mqid)
  edit_match_id = edit_matching_id(qid, mqid, '2')
  if clicked_box in [0,1] #what to do with edit options
    $("##{delete_id}").prop("checked", false)
    for modifier_type in ['q_p', 'q_v', 'i_p', 'i_l', 'a_p', 'a_v', 'a_o', 'a_t', 'o']
      match_type_id = edit_match_option_id(qid,mqid,modifier_type)
      $("##{match_type_id}").prop("checked", false)
  if clicked_box in ['+'] #what to do with mod types
      $("##{delete_id}").prop("checked", false)
      $("##{edit_match_id}").prop("checked", true)
  if clicked_box in ['delete']
    for nums in [0,1,2]
      eddie = edit_match_option_id(qid,mqid,nums)
      $("##{eddie}").prop("checked", false)
    for modifier_type in ['q_p', 'q_v', 'i_p', 'i_l', 'a_p', 'a_v', 'a_o', 'a_t', 'o']
      match_type_id = edit_match_option_id(qid,mqid,modifier_type)
      $("##{match_type_id}").prop("checked", false)
    return 0

root.matching_new_logic = (qid, clicked_box) ->
  edit_match_id = new_matching_id(qid, 'modified_plus')
  #console.log("#{edit_match_id} is our edit_match_id, our qid is #{qid} and our clicked_box is #{clicked_box}")
  if clicked_box in [0, 1, 'clear', '']
    # uncheck modified+ categories if we picked identical, modified, clear, or unknown
    for modifier_type in ['q_p', 'q_v', 'i_p', 'i_l', 'a_p', 'a_v', 'a_o', 'a_t', 'o']
      match_type_id = new_match_option_id(qid, modifier_type)
      #console.log("match_type_id is #{match_type_id}")
      $("##{match_type_id}").prop("checked", false)
  if clicked_box in ['+']
    # any modified+ category checks modified+
    $("##{edit_match_id}").prop("checked", true)

  # check the box for is_match if we selected match_type identical,
  # modified, or modified+
  # if we pick unknown for match_type, then also pick unknown for is_match
  if clicked_box != ''
    is_match = "questions_#{qid}_is_match_1"
  else if clicked_box == ''
    is_match = "questions_#{qid}_is_match_"
  is_match_html = $("##{is_match}")
  is_match_html.prop("checked", true)
  console.log("is match HTML: #{is_match_html}")
  return 0
