class Event < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :start_datetime, presence: true
  scope :in_range, ->(s, e) { where("start_datetime < ? AND (end_datetime > ? OR start_datetime >= ?)", e, s, s) }
  scope :ordered, -> { order(:start_datetime) }

  def as_fullcalendar_json
    { id:, title:, allDay: all_day,
      start: all_day ? start_datetime.to_date.iso8601 : start_datetime.iso8601,
      end: end_datetime&.then { |d| all_day ? d.to_date.iso8601 : d.iso8601 },
      url: Rails.application.routes.url_helpers.event_path(self) }
  end
end
