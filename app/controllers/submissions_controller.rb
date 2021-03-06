class SubmissionsController < ApplicationController
  def create
    @submission = current_user.submissions.build(
      source: params[:submission][:source] && params[:submission][:source].read,
      path: params[:submission][:source] && params[:submission][:source].original_filename,
      task_id: params[:task_id]
    )

    if @submission.save
      flash[:notice] = "Submitted solution!"
      redirect_to task_path(params[:task_id])
    else
      @task = @submission.task
      @submissions = current_user.submissions.where(task_id: @task.id).order("id DESC")
      render "tasks/show"
    end
  end

  def show
    @submission = current_user.submissions.find(params[:id])
  end
end
