require 'benchmark'

class MeetupScheduleService
  def initialize(first_day, last_day)
    @first_day = first_day
    @last_day = last_day
    @meetings = {}
    @one_day_investors = {}
    puts [@first_day.size, @last_day.size].inspect
  end

  def call
    sorted_investors = setup_investors_schedules
    return @one_day_investors.size if @one_day_investors.size == sorted_investors.size
    investors = schedule_meetings_with_single_day_investors(sorted_investors)
    unscheduled_investors = schedule_meetings_with_other_investors(investors)
    @meetings.size
  end

  private

  # schedule meetings with investors that are available one day
  def schedule_meetings_with_single_day_investors(investors)
    investors.each do |investor_range|
      next unless investor_range.size == 1
      day = investor_range.first
      @meetings[day] = true unless @meetings[day]
      investors.delete(investor_range)
    end
    investors
  end

  # schedule meetings with the rest of investors
  def schedule_meetings_with_other_investors(investors)
    investors.each do |investor_range|
      investor_range.each do |day|
        next if @meetings[day]
        @meetings[day] = true
        break
      end
    end
    investors
  end

  def setup_investors_schedules
    investors = []
    (0...@first_day.size).each do |index|
      range = (@first_day[index]..@last_day[index])
      investors << range
      @one_day_investors[@first_day[index]] = true if range.size == 1
    end
    investors.sort{ |x, y| x.first <=> y.first && x.last <=> y.last }
  end
end

def countMeetings(firstDay, lastDay)
  MeetupScheduleService.new(firstDay, lastDay).call
end

# puts Benchmark.measure{
# puts countMeetings([1, 1, 2], [1, 2, 2])
puts countMeetings((1..10000).to_a, (1..10000).to_a)
# puts countMeetings([1, 10, 11], [11, 10, 11])
# }
