class ReleaseLogConfigurationsController < ReleaseLogsBaseController
  include ReleaseLogsHelper

  unloadable

  helper :release_logs

  before_filter :authorize_global
  before_filter :load_configuration, :only => [:edit, :update, :destroy]
  before_filter :load_dependencies, :only => [:new, :edit]

  def index
    @release_log_configurations = ReleaseLogConfiguration.all
  end

  def new
    @release_log_configuration = ReleaseLogConfiguration.new
  end

  def create
    @release_log_configuration = ReleaseLogConfiguration.new params[:release_log_configuration]
    save_configuration
  end

  def edit
    @valid_project_selections << @release_log_configuration.project
  end

  def update
    @release_log_configuration.assign_attributes params[:release_log_configuration]

    save_configuration
  end

  def destroy
    @release_log_configuration.destroy
    flash[:notice] = release_logs_label_for(:configuration_destroyed, :project => @release_log_configuration.project.name)
    redirect_to release_log_configurations_path
  end

  protected

  def load_configuration
    @release_log_configuration = ReleaseLogConfiguration.find(params[:id])
  end

  def load_dependencies
    @valid_project_selections = Project.all - ReleaseLogConfiguration.all.map(&:project)
    @release_log_queues = ReleaseLogQueue.all
  end

  def save_configuration
    new_record = @release_log_configuration.new_record?
    if @release_log_configuration.save
      flash[:notice] = release_logs_label_for(:"configuration_#{new_record ? 'created' : 'updated'}", :project => @release_log_configuration.project.name)
      redirect_to release_log_configurations_path
    else
      load_dependencies
      render new_record ? :new : :edit
    end
  end
end
