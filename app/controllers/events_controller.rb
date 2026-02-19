class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def feed
    start_time = Time.zone.parse(params[:start]) rescue 1.month.ago
    end_time   = Time.zone.parse(params[:end])   rescue 1.month.from_now
    @events = current_user.events.in_range(start_time, end_time)
    render json: @events.map(&:as_fullcalendar_json)
  end

  def index
    @events = current_user.events.ordered
  end

  def new
    @event = current_user.events.new(
      start_datetime: params[:start],
      end_datetime: params[:end],
      all_day: params[:all_day] == "true"
    )
  end

  def create
    @event = current_user.events.new(event_params)
    if @event.save
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Event created." }
        format.turbo_stream { render turbo_stream: turbo_stream.action(:refresh, "") }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def show; end
  def edit; end

  def update
    if @event.update(event_params)
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Event updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.action(:refresh, "") }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Event deleted." }
      format.turbo_stream { render turbo_stream: turbo_stream.action(:refresh, "") }
    end
  end

  private

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :start_datetime, :end_datetime, :description, :all_day)
  end
end