require 'byebug'
class MinimumMovementService
  LEFT_LANE = 1
  MIDDLE_LANE = 2
  RIGHT_LANE = 3

  def initialize(obstacleLanes, starting_lane = MIDDLE_LANE)
    @obstacleLanes = obstacleLanes
    @car_lane = starting_lane
  end

  def call
    movements = 0
    index = 0
    while index < @obstacleLanes.size
      obstacle = @obstacleLanes[index]
      if obstacle == @car_lane
        movements += 1
        next_obstacles = @obstacleLanes.slice(index + 1..-1)
        break if next_obstacles.empty?
        next_lane_index = find_next_lane_index(next_obstacles)
        index += next_lane_index.positive? ? next_lane_index : 0
      end
      index += 1
    end
    movements
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
    elsif index_lane1 >= index_lane2 # lane 1 last longer
      @car_lane = lane1
      index_lane1
    else # lane 1 last longer
      @car_lane = lane2
      index_lane2
    end
  end
end

def minimumMovement(obstacleLanes)
  MinimumMovementService.new(obstacleLanes).call
end

# obstacleLanes = [2, 3, 2, 1, 3, 1]
obstacleLanes = [2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
puts minimumMovement(obstacleLanes)
