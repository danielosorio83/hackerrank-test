# frozen_string_literal: true

class TimeRequestsService
  DATETIME_FORMAT = %r{\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2}}.freeze

  def initialize(filename)
    @filename = filename
    @datetimes = {}
  end

  def call
    datetimes = pull_datetimes_from_file
    generate_req_file(datetimes)
  end

  def pull_datetimes_from_file
    file = File.open(@filename)
    file.readlines.each do |line|
      datetime = line.match(DATETIME_FORMAT)[0]
      next unless datetime

      @datetimes[datetime] ||= 0
      @datetimes[datetime] += 1
    end
  end

  def generate_req_file(_datetimes)
    output = File.open("req_#{@filename}", 'w+')
    @datetimes.each do |datetime, count|
      next if count == 1

      output.print("#{datetime}\n")
    end
    output
  end
end
