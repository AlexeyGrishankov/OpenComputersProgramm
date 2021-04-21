local robot = require("robot")

function Forward(count)
    for i = 0, count-1, 1 do
        robot.forward()
        os.sleep(1)
    end
end

function Up(count)
    for i = 0, count-1, 1 do
        robot.up()
        os.sleep(1)
    end
end

function Back(count)
    for i = 0, count-1, 1 do
        robot.back()
        os.sleep(1)
    end
end

function Left(count)
    robot.turnLeft()
    for i = 0, count-1, 1 do
        robot.forward()
        os.sleep(1)
    end
end

function Right(count)
    robot.turnRight()
    for i = 0, count-1, 1 do
        robot.forward()
        os.sleep(1)
    end
end
