class EntriesController < ApplicationController
  DATE_FORMAT = "%d/%m/%Y"

  def create
    @entry = Entry.new(entry_params)
    @entry.user = current_user
    if @entry.save
      redirect_to root_path, notice: t(:entry_created)
    else
      redirect_to root_path, notice: @entry.errors.full_messages.join(" ")
    end
  end

  def index
    @user = User.find_by_slug(params[:user_id])
    respond_to do |format|
      format.html { @entries = @user.entries.by_date.page(params[:page]).per(20) }
      format.csv { send_csv(@user) }
    end
  end

  def update
    if resource.update_attributes(entry_params)
      redirect_to user_entries_path(current_user), notice: t("entry_saved")
    else
      render "edit", notice: t("entry_failed")
    end
  end

  def edit
    resource
  end


  def destroy
    resource.destroy
    redirect_to user_entries_path(current_user), notice: t('entry_deleted')
  end

  private

  def resource
    @entry ||= current_user.entries.find(params[:id])
  end

  def entry_params
    params.require(:entry)
      .permit(:project_id, :category_id, :hours, :description, :date)
      .merge(date: parsed_date)
  end

  def parsed_date
    Date.strptime(params[:entry][:date], DATE_FORMAT)
  end

  def send_csv(user)
    send_data(
      EntryCSVGenerator.generate(user.entries.by_date),
      filename: "#{user.full_name}-entries-#{DateTime.now}.csv",
      type: "text/csv"
    )
  end
end
