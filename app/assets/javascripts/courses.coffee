# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this

update_match_stats = (data) ->
  for id, count of data.possible_matches
    $("#possible_match_#{id}").html("#{count}")
  for id, count of data.matches
    $("#match_#{id}").html("#{count}")
  for id, count of data.nonmatches
    $("#nonmatch_#{id}").html("#{count}")

root.course_index_load =() ->
  $ ->
    $.ajax
      url: "/ajax/courses"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        update_match_stats(data)

root.course_show_load =(course_id) ->
  $ ->
    $.ajax
      url: "/ajax/courses/#{course_id}"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        update_match_stats(data)
