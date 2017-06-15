class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
    # TODO sort sessions by date
    # Using classes instead of sessions because "session" means other things
    #   for a web service.
    @classes = Session.where(course_id: @course.id)
  end
end
