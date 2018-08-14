class MatchController < ApplicationController
  include ApplicationHelper

  def index
    # TODO 
  end

  def show
    matches = get_match_stats(ClassPeriod.find_by(id: params[:id]))
    respond_to do |format|
      format.html { render json: matches }
      format.json { render json: matches }
    end
  end

  private

  def get_match_stats(class_period)
    matches = Hash.new
    class_period.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => 1}).each do |mq|
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(matches, q.id)
      end
    end

    possible_matches = Hash.new
    class_period.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => nil}).each do |mq|
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(possible_matches, q.id)
      end
    end

    nonmatches = Hash.new
    class_period.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => 0}).each do |mq|
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(nonmatches, q.id)
      end
    end

    return {"matches" => matches,
            "possible_matches" => possible_matches,
            "nonmatches" => nonmatches}
  end

end
