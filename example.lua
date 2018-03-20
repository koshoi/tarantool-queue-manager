local manager = require 'manager'
local M = {
	qm = manager.attach_on_queue('test', {})
}

function M.process_queue(generation)
	fiber.name('tester_worker')
	while generation >= qm.generation do
		local task = M.qm.take(0)
		if not task then
			fiber.sleep(5)
		else
			local ok, status = pcall(M.on_task, task)
			if not ok then
				task:fail(status)
			end
		end
	end
end

function M.on_task(task)
	task:log_info("Started a task=%s", task)
	local data = task.data
	local success = data.success or 8
	local all = data.all or 10
	local res = math.random(all)
	if (res > success) then
		task:log_info("OK")
		return task:success(res)
	else
		task:log_error("FAIL")
		return task:fail(res)
	end
end

return M
