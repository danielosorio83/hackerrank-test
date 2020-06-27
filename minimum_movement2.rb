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
    @obstacleLanes.each_with_index do |obstacle, i|
      if obstacle == @car_lane
        movements += 1
        next_obstacles = @obstacleLanes.slice(i+1..-1)
        break unless next_obstacles.include?(obstacle)

        if obstacle == RIGHT_LANE || obstacle == LEFT_LANE
          @car_lane = MIDDLE_LANE
        end
      end
    end
    movements
  end
end
