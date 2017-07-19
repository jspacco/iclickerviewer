# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this
root.question_pair_handler =(question_index, question_pair) ->
  console.log("question_index " + question_index +
    " question_pair "+ question_pair)
  if question_index == ''
    return 0

  # For question_index 3 and question_pair 4:
  #   set question_type=paired for question_index 3 class question_type
  #   set question_type=paired for question_index 4 class question_type
  #   set question_pair=3 for question_index 4
  #
  # question type (enum):
  # <select id="questions_15_question_type">
  # question pair (numbers):
  # <select id="questions_15_question_pair">
  #
  # 1: quiz
  # 2: single
  # 3: paired
  # 4: non-MCQ
  # 5: error
  #
  type_index = "select.question_type_#{question_index}"
  type_pair = "select.question_type_#{question_pair}"
  paired_pair = "select.question_pair_#{question_pair}"

  jQuery ->
    $(type_index).val('3')
  jQuery ->
    $(type_pair).val('3')
  jQuery ->
    $(paired_pair).val("#{question_index}")

  return 0
