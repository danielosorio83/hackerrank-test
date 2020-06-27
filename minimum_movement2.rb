# frozen_string_literal: true

class MinimumMovementService
  LEFT_LANE = 1
  MIDDLE_LANE = 2
  RIGHT_LANE = 3

  def initialize(obstacle_lanes, starting_lane = MIDDLE_LANE)
    @obstacle_lanes = obstacle_lanes
    @car_lane = starting_lane
  end

  def call
    movements = 0
    @obstacle_lanes.each_with_index do |obstacle, i|
      next unless obstacle == @car_lane

      movements += 1
      next_obstacles = @obstacle_lanes.slice(i + 1..-1)
      break unless next_obstacles.include?(obstacle)

      @car_lane = MIDDLE_LANE if [RIGHT_LANE, LEFT_LANE].include?(obstacle)
    end
    movements
  end
end
