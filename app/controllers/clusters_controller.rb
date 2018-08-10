class ClustersController < ApplicationController
  def show
    @cluster_show = Question.joins(:class_period).where(id: get_question_cluster).order('class_periods.date')

  end


  def get_question_cluster
    #build the cluster recursively, from start_spot
    @cluster = Set.new #contains qid of all questions in cluster
    @used = Set.new
    make_cluster(@cluster, params[:id], @used)
    @cluster.each do |q|
      puts "#{q} is in the cluster of #{params[:id]}"
    end
  end

  def make_cluster(set, qid, used)
    qid=qid.to_i #qid was a string from
    set.add(qid)
    other_id = -1
    matches = MatchingQuestion.where(question_id: qid).or(MatchingQuestion.where(matching_question_id: qid))
    matches.each do |match|
      #puts "Question ID: #{match.question_id}"
      #puts "Matching QID: #{match.matching_question_id}"
      #puts "QID: #{qid}"
      if match.question_id == qid
        #puts "These are the matches for #{qid}: "
        other_id = match.matching_question_id
      elsif match.matching_question_id == qid
        other_id = match.question_id
      end
      #puts "Other ID: #{other_id}"
      #puts "These are the matches for #{qid}: #{other_id}"
      if !used.include?(other_id)
        used.add(other_id)
        make_cluster(set, other_id, used)
      end
    end
  end
end
