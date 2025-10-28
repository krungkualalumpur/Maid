--!strict
--services
--types
export type Maid = {
	__index : Maid,
	__newindex : (t : Maid, k:any, v:any) -> (),
	
	_taskHandler : {[any] : any},
	
	new : () -> Maid,
	GiveTask :<T> (maid : Maid, job : T) -> (T, number),
	DoCleaning : (maid : Maid) -> (),
	Destroy : (maid : Maid) -> (),
	
	[any] : any
}
--module
local Maid : Maid = {} :: any 
Maid.__index = Maid
Maid.__newindex = function(t, k, v)
	if k == "_taskHandler" then
		rawset(t,k,v)
	elseif t._taskHandler then
		local intJob = t._taskHandler[k]
		
		if (type(v) == "table" and type(v.Destroy) == "function") or (typeof(v) == "Instance") or (typeof(v) == "RBXScriptConnection") or (typeof(v) == "nil") then
			t._taskHandler[k] = v
		else
			error('Bad job!')
		end

		if (type(intJob) == "table" and type(intJob.Destroy) == "function") or (typeof(intJob) == "Instance") then
			intJob:Destroy()
		elseif (typeof(intJob) == "RBXScriptConnection") then
			intJob:Disconnect()
		end
		
	end
end

function Maid.new()
	local self : Maid = setmetatable({}, {
		__index = function(t, k)
			return if (type(Maid[k]) == "function") or (k == "_taskHandler") then Maid[k] elseif t._taskHandler then t._taskHandler[k] else nil
		end,
		__newindex = Maid.__newindex
	}) :: any
	self._taskHandler = {}
	
	
	return self
end

function Maid:GiveTask<T>(job : T)
	local index = #self._taskHandler + 1
	self._taskHandler[index] = job
	return self._taskHandler[index], index
end

function Maid:DoCleaning()
	for k,v in pairs(self._taskHandler) do
		if (type(v) == "table" and type(v.Destroy) == "function") or (typeof(v) == "Instance") then
			v:Destroy()
		elseif (typeof(v) == "RBXScriptConnection") then
			v:Disconnect()
		end
		self._taskHandler[k] = nil
	end
	return
end

function Maid:Destroy()
	self:DoCleaning()
	
	for k,v in pairs(self) do
		self[k] = nil
	end
	
	setmetatable(self, nil)
	return
end

return Maid
