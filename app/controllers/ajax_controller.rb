class AjaxController < ApplicationController
  include ApplicationHelper

  def show_all_courses
    matches = get_match_stats_all_courses
    respond_to do |format|
      format.html { render json: matches }
      format.json { render json: matches }
    end
  end

  def show_course
    matches = get_match_stats_course(params[:id])
    respond_to do |format|
      format.html { render json: matches }
      format.json { render json: matches }
    end
  end

  private

  # ----------------------------------------------------------------
  # Get mapping of course_id to counts of matches, possible matches,
  # and nonmatches.
  # ----------------------------------------------------------------
  def get_match_stats_all_courses
    matches = Hash.new
    possible_matches = Hash.new
    nonmatches = Hash.new
    Question.includes(:class_period).each do |q|
      q.matching_questions.each do |mq|
        if mq.is_match == 1
          increment(matches, q.class_period.course_id)
        elsif mq.is_match == 0
          increment(nonmatches, q.class_period.course_id)
        elsif mq.is_match == nil
          increment(possible_matches, q.class_period.course_id)
        end
      end
    end
    return {"matches" => matches,
            "possible_matches" => possible_matches,
            "nonmatches" => nonmatches}
  end

  # ----------------------------------------------------------------
  # Get match stats for one course. Map class_period_ids to counts of
  # matches, possible matches, nonmatches.
  # ----------------------------------------------------------------
  def get_match_stats_course(course_id)
    matches = Hash.new
    possible_matches = Hash.new
    nonmatches = Hash.new
    Question.joins(:class_period).where(:class_periods => {course_id: course_id}).each do |q|
      q.matching_questions.each do |mq|
        if mq.is_match == 1
          increment(matches, q.class_period_id)
        elsif mq.is_match == 0
          increment(nonmatches, q.class_period_id)
        elsif mq.is_match == nil
          increment(possible_matches, q.class_period_id)
        end
      end
    end
    return {"matches" => matches,
            "possible_matches" => possible_matches,
            "nonmatches" => nonmatches}
  end
end
