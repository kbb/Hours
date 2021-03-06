class TimeSeries::YearlyTimeSeries < TimeSeries
  def initialize(resource)
    @resource = resource
    @time_span = (364.days.ago.to_date..Date.today).freeze
  end

  def chart
    "/charts/line_chart"
  end

  private

  def data
    @time_span.step(7).map { |week| hours_per_week(week) }
  end

  def labels
    @time_span.step(7).map { |date| date.strftime('%V') }
  end

  def hours_per_week(week)
    @resource.entries.where(date: ((week-1.week)..week)).sum(:hours)
  end
end
