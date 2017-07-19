# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this
root.question_pair_handler =(question_index, question_pair, old_question_pair) ->
  console.log("question_index #{question_index} question_pair #{question_pair} old_question_pair #{old_question_pair}")
  # First, unset anything matching question_index
  type_index = "select.question_type_#{question_index}"
  type_pair = "select.question_type_#{question_pair}"
  paired_pair = "select.question_pair_#{question_pair}"

  # Remember that the question_types are:
  # 0: unknown
  # 1: quiz
  # 2: single
  # 3: paired
  # 4: non-MCQ
  # 5: error
  jQuery ->
    #
    # if old_question_pair != '' and question_pair != '' then unset old_question_pair and update question_pair
    #
    if old_question_pair == ''
      if question_pair != ''
        # old_question_pair == '' and question_pair != '' then update question_pair
        console.log('regular update')
        $(type_index).val('3')
        $(type_pair).val('3')
        $(paired_pair).val("#{question_index}")
      else
        # if old_question_pair == '' and question_pair == '' then something went wrong
        alert('probably an error')
    else
      # if old_question_pair != '' then unset old_question_pair
      console.log("unset #{old_question_pair}")
      $("select.question_type_#{question_index}").val('0')
      $("select.question_type_#{old_question_pair}").val('0')
      $("select.question_pair_#{old_question_pair}").val('')
      if question_pair != ''
        # if question_pair == '' then update
        console.log('update after unset')
        $(type_index).val('3')
        $(type_pair).val('3')
        $(paired_pair).val("#{question_index}")
  return 0
