# frozen_string_literal: true

require 'byebug'
class MinimumMovementService
  LEFT_LANE = 1
  MIDDLE_LANE = 2
  RIGHT_LANE = 3

  def initialize(obstacle_lanes, starting_lane = MIDDLE_LANE)
    @obstacle_lanes = obstacle_lanes
    @car_lane = starting_lane
    @movements = 0
  end

  def call
    initiate_car_movements
    @movements
  end

  def initiate_car_movements(index = 0)
    while index < @obstacle_lanes.size
      obstacle = @obstacle_lanes[index]
      begin
        index += obstacle_in_same_lane(index) if obstacle == @car_lane
      rescue EndOfLaneError
        break
      end
      index += 1
    end
  end

  def obstacle_in_same_lane(index)
    @movements += 1
    next_obstacles = @obstacle_lanes.slice(index + 1..-1)
    raise EndOfLaneError, 'EndOfLaneError' if next_obstacles.empty?

    next_lane_index = find_next_lane_index(next_obstacles)
    next_lane_index.positive? ? next_lane_index : 0
  end

  def find_next_lane_index(next_obstacles)
    case @car_lane
    when LEFT_LANE
      find_index_and_change_lane(next_obstacles, MIDDLE_LANE, RIGHT_LANE)
    when RIGHT_LANE
      find_index_and_change_lane(next_obstacles, LEFT_LANE, MIDDLE_LANE)
    else # MIDDLE_LANE
      find_index_and_change_lane(next_obstacles, LEFT_LANE, RIGHT_LANE)
    end
  end

  def find_index_and_change_lane(next_obstacles, lane1, lane2)
    index_lane1 = next_obstacles.index(lane1).to_i
    index_lane2 = next_obstacles.index(lane2).to_i
    if !index_lane1 || !index_lane2 # no more obstacles in lanes
      @car_lane = !index_lane1 ? lane1 : lane2
      next_obstacles.size
    else
      change_lane(lane1, lane2, index_lane1, index_lane2)
    end
  end

  def change_lane(lane1, lane2, index_lane1, index_lane2)
    if index_lane1 >= index_lane2 # lane 1 last longer
      @car_lane = lane1
      index_lane1
    else # lane 1 last longer
      @car_lane = lane2
      index_lane2
    end
  end
end

class EndOfLaneError < StandardError; end

def minimumMovement(obstacle_lanes) # rubocop:disable Naming/MethodName
  MinimumMovementService.new(obstacle_lanes).call
end

# obstacle_lanes = [2, 3, 2, 1, 3, 1]
obstacle_lanes = [2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
puts minimumMovement(obstacle_lanes)
