class ClustersController < ApplicationController
  def show
    get_question_cluster
  end


  def get_question_cluster
    #build the cluster recursively, from start_spot
    @cluster = Set.new
    make_cluster(@cluster, params[:id])
    @cluster.each do |q|
      puts q.question_id
    end
  end

  def make_cluster(set, qid)
    set.merge(MatchingQuestion.where(question_id: params[:id]).or(MatchingQuestion.where(matching_question_id: params[:id])))
    set.each do |q|
      make_cluster(set, qid)
    end
  end
end
