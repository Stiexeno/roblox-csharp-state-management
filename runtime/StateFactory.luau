-- DI-aware factory. Each Create(stateClass) delegates to the
-- container's auto-bound IInstantiator, which constructs the state
-- with DI-resolved ctor args without requiring the state to be
-- bound. States are transient — Enter<TState>() produces a fresh
-- instance every call.
--
-- Binding shape on the user side:
--
--     Container.BindInterfacesTo<StateFactory>().AsSingle();

local StateFactory = setmetatable({}, {
	__tostring = function() return "StateFactory" end,
})
StateFactory.__index = StateFactory

StateFactory.__ctorParams = { "IInstantiator" }
StateFactory.__interfaces = { "IStateFactory" }

function StateFactory.new(...)
	local self = setmetatable({}, StateFactory)
	return self:constructor(...) or self
end

function StateFactory:constructor(instantiator)
	self._instantiator = instantiator
end

-- `Create<TState>()` lowers via the standard generic-arg pass to
-- `Create(stateClass)` where stateClass is the C# type table.
-- Validated up front — a nil / non-class argument would otherwise
-- error deep inside the instantiator's `__ctorParams` walk.
function StateFactory:Create(stateClass)
	if stateClass == nil then
		error("StateFactory:Create — state class is nil", 2)
	end
	if type(stateClass) ~= "table" or type(rawget(stateClass, "new")) ~= "function" then
		error("StateFactory:Create — expected a state class, got "
			.. typeof(stateClass) .. " (" .. tostring(stateClass) .. ")", 2)
	end
	return self._instantiator:Instantiate(stateClass)
end

return StateFactory
