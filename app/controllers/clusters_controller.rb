class ClustersController < ApplicationController
  def show
    ids = get_question_cluster
    @cluster_show = Question.joins(:class_period).where(id: ids).order('class_periods.date')
    # Match and show QID mapped to its list of matches
    # TODO find all the questions that this question matches
    # then match everything to it
    # then match everything to each of these
    @cluster_hash = Hash.new
    for qid in ids
      @cluster_hash[qid] = []
      MatchingQuestion.where(question_id: qid).each do |m|
        @cluster_hash[qid] << m.matched_question
      end
    end
  end


  def get_question_cluster
    #build the cluster recursively, from start_spot
    # the cluster is a set of the questions that match this one
    cluster = Set.new #contains qid of all questions in cluster
    make_cluster(cluster, params[:id], Set.new)
    return cluster
  end

  def make_cluster(set, qid, used)
    qid = qid.to_i #qid was a string from
    set.add(qid)
    other_id = -1
    #matches = MatchingQuestion.where(question_id: qid).or(MatchingQuestion.where(matching_question_id: qid))
    MatchingQuestion.where(question_id: qid).each do |match|
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
