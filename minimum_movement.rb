# frozen_string_literal: true

require 'byebug'
class MinimumMovementService
  LEFT_LANE = 1
  MIDDLE_LANE = 2
  RIGHT_LANE = 3

  def initialize(obstacle_lanes, starting_lane = MIDDLE_LANE, start_movements = 0)
    @obstacle_lanes = obstacle_lanes
    @car_lane = starting_lane
    @movements = start_movements
  end

  def call
    return 0 if @obstacle_lanes.empty?
    return @movements unless @obstacle_lanes.include?(@car_lane)

    first_obstacle = @obstacle_lanes[0]
    next_obstacles = @obstacle_lanes.slice(1..-1)
    @movements + next_movement(first_obstacle, next_obstacles)
  end

  def next_movement(obstacle, next_obstacles)
    return 0 if next_obstacles.empty?

    if obstacle != @car_lane
      return 0 unless next_obstacles.include?(@car_lane)

      next_obstacles = find_next_obstacle_in_same_lane(next_obstacles)
    end
    move_car_lane(next_obstacles)
  end

  def find_next_obstacle_in_same_lane(next_obstacles)
    i = next_obstacles.index(@car_lane)
    next_obstacles.slice(i..-1)
  end

  def move_car_lane(next_obstacles)
    case @car_lane
    when LEFT_LANE
      lane_movement(next_obstacles, RIGHT_LANE, MIDDLE_LANE)
    when MIDDLE_LANE
      lane_movement(next_obstacles, RIGHT_LANE, LEFT_LANE)
    when RIGHT_LANE
      lane_movement(next_obstacles, MIDDLE_LANE, LEFT_LANE)
    else
      0
    end
  end

  def lane_movement(next_obstacles, lane1, lane2)
    lane1_movements = MinimumMovementService.new(next_obstacles, lane1, @movements).call + 1
    lane2_movements = MinimumMovementService.new(next_obstacles, lane2, @movements).call + 1
    [lane1_movements, lane2_movements].min
  end
end

def minimumMovement(obstacle_lanes) # rubocop:disable Naming/MethodName
  MinimumMovementService.new(obstacle_lanes).call
end

# obstacle_lanes = [2, 3, 2, 1, 3, 1]
obstacle_lanes = [2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
puts minimumMovement(obstacle_lanes)
