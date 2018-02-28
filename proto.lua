local queue = require('queue')
local qm = require('qmanager')

local q1 = queue.create_tube('q1', fifottl, { temporary = false, if_not_exists = true })

function task_handler (task)
	task:log.info("Got new task=%s", task)
	if not task.message then
		task:log.error("I have no message for task=%s", task)
		return task:fail()
	end

	task:log("Message for you: %s", task.message)
	return task:success("Successfully finished task")
end

function delay_handler (task, delay)
	if not delay then
		return nil
	end

	delay = delay * 2
	if delay >= 3600*30 then
		return 3600*30
	else
		return delay
	end
end

local qm1 = qm.start_queue({
	queue = 'q1',
	handler = task_handler,
	on_delay = delay_handler,
	safe = true
})

qm1:put({ event = 'Birthday', message = 'Happy Birthday!!!' }, { delay = 3600*7 })
qm1:put({ event = 'Morning', message = 'Good Morning!!!' }, { delay = 1800 })
qm1:put({ event = 'No message' })

-- The main point of this whole idea is that every task is being put by a wrapper
-- This wrapper gives every task a __prefix, that is being used for logging
-- So every task can log itself with it's own prefix, which makes it easier to parse logs
-- Putting task to queue can also be logged with it's new __prefix

-- All of this options should be configurable
-- I still have to think about comfortable way of doing it

----------------------------------------
-- Ideas, what should be configurable --
----------------------------------------

-- task_handler
-- safe/unsafe queue (whether it uses pcall on task_handler or not)
-- callback on (putting/taking/acking/releasing/burying) task
-- function that works with delay
-- prefix generator
-- task serializer that is going ot be used inside __tostring metamethod
-- logging functions
-- maybe something else
