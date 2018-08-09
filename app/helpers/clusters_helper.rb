module ClustersHelper
  def make_cluster(set, qid)
    set.merge(MatchingQuestion.where(question_id: params[:id]).or(MatchingQuestion.where(matching_question_id: params[:id])))
    set.each do |q|
      cluster_helper(set, qid)
    end
  end
end
