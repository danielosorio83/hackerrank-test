require 'byebug'
class MinimumMovementService
  LEFT_LANE = 1
  MIDDLE_LANE = 2
  RIGHT_LANE = 3

  @@used_chars = []

  def initialize(obstacleLanes, starting_lane = MIDDLE_LANE, start_movements = 0)
    @obstacleLanes = obstacleLanes
    @car_lane = starting_lane
    @movements = start_movements
    @sample = get_sample_char
  end

  def call
    return 0 if @obstacleLanes.empty?
    return @movements unless @obstacleLanes.include?(@car_lane)
    first_obstacle = @obstacleLanes[0]
    next_obstacles = @obstacleLanes.slice(1..-1)
    # hash = {car_lane: @car_lane, next_obstacle: first_obstacle, movements: @movements, next_obstacles: next_obstacles}
    # puts "#{@sample} #{' ' * @sample}#{hash.inspect}"
    @movements + next_movement(first_obstacle, next_obstacles)
  end

  def next_movement(obstacle, next_obstacles)
    return 0 if next_obstacles.empty?
    if obstacle == @car_lane
      move_car_lane(next_obstacles)
    else
      return 0 unless next_obstacles.include?(@car_lane)
      next_obstacles = find_next_obstacle_in_same_lane(next_obstacles)
      # MinimumMovementService.new(next_obstacles, @car_lane, @movements).call
      move_car_lane(next_obstacles)
    end
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
    # puts @sample*10
    # hash1 = {movements: @movements, car_lane: @car_lane, lane1: lane1, lane2: lane2, next_obstacles: next_obstacles}
    # puts "#{@sample} #{' ' * @sample}#{hash1.inspect}"
    lane1_movements = MinimumMovementService.new(next_obstacles, lane1, @movements).call + 1
    lane2_movements = MinimumMovementService.new(next_obstacles, lane2, @movements).call + 1
    # hash2 = hash1.merge({lane1_movements: lane1_movements, lane2_movements: lane2_movements})
    # puts "#{@sample} #{' ' * @sample}#{hash2.inspect}"
    # puts @sample*20
    [lane1_movements, lane2_movements].min
  end

  def get_sample_char(sample = 0)
    loop do
      sample += 1
      break if !@@used_chars.include?(sample)
    end
    @@used_chars << sample
    sample
  end
end

def minimumMovement(obstacleLanes)
  MinimumMovementService.new(obstacleLanes).call
end

# obstacleLanes = [2, 3, 2, 1, 3, 1]
obstacleLanes = [2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
puts minimumMovement(obstacleLanes)
