Tools = {}

local IDGenerator = {}

function Tools.newIDGenerator()
	local generatorInstance = setmetatable({}, { __index = IDGenerator })
	
	generatorInstance:construct()

	return generatorInstance
end

function IDGenerator:construct()
	self:clear()
end

function IDGenerator:clear()
	self.max = 0
	self.ids = {}
end

function IDGenerator:gen()
	if #self.ids > 0 then
		return table.remove(self.ids)
	else
		local newId = self.max

		self.max = self.max + 1

		return newId
	end
end

function IDGenerator:free(id)
	table.insert(self.ids, id)
end