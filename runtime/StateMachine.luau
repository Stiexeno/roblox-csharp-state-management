-- Base state machine. The user's GameStateMachine subclass inherits
-- from this; binding via `BindInterfacesTo<GameStateMachine>().AsSingle()`
-- registers the machine under every interface it implements
-- (IStateMachine + IInitializable, plus the user's own IGameStateMachine
-- if they added one).
--
-- Lifecycle interfaces are name-checked against each state's
-- `__interfaces` table (compiler-emitted) so adding or removing a
-- hook just means adding / removing an interface implementation on
-- the state class — no separate registration.
--
-- Per-frame dispatch is driven by RunService:
--   IExecutable       → RunService.Heartbeat     (server + client)
--   IFixedExecutable  → RunService.Stepped       (server + client)
--   ILateExecutable   → RunService.RenderStepped (client only)
-- The RenderStepped subscription is gated by RunService:IsClient()
-- so the server doesn't try to bind a render hook that doesn't
-- exist in its context.

local RunService = game:GetService("RunService")

local StateMachine = setmetatable({}, {
	__tostring = function() return "StateMachine" end,
})
StateMachine.__index = StateMachine

StateMachine.__ctorParams = { "IStateFactory" }
StateMachine.__interfaces = { "IStateMachine", "IInitializable" }

function StateMachine.new(...)
	local self = setmetatable({}, StateMachine)
	return self:constructor(...) or self
end

function StateMachine:constructor(factory)
	self._factory = factory
	self._current = nil
end

-- Walks an instance's class + base-class metatable chain collecting
-- every interface declared at any level. Same shape Container uses
-- for IInitializable detection — the lifecycle check has to honour
-- inheritance so a state that subclasses an abstract base picks up
-- the base's IExecutable / etc.
local function collectInterfaces(instance)
	local result = {}
	local class = getmetatable(instance) and getmetatable(instance).__index
	while class ~= nil do
		local interfaces = rawget(class, "__interfaces")
		if interfaces then
			for _, iface in ipairs(interfaces) do
				result[iface] = true
			end
		end
		local mt = getmetatable(class)
		class = mt and mt.__index or nil
	end
	return result
end

local function implements(instance, interfaceName)
	if instance == nil then return false end
	local interfaces = collectInterfaces(instance)
	return interfaces[interfaceName] == true
end

-- `Enter<TState>()` lowers to `Enter(stateClass)` — stateClass is
-- the C# type's table. Runs the standard transition sequence:
--   1. Current state's Exit (if it has one)
--   2. Construct the new state via the factory (DI-resolved)
--   3. Swap current
--   4. New state's Enter (if it has one)
-- The per-frame dispatch then sees the new current.
function StateMachine:Enter(stateClass)
	if self._current ~= nil and implements(self._current, "IExit") then
		self._current:Exit()
	end
	self._current = self._factory:Create(stateClass)
	if implements(self._current, "IEnter") then
		self._current:Enter()
	end
end

-- IInitializable hook. Container.Bootstrap() instantiates singletons
-- bound under IInitializable and fires Initialize() — this is when
-- we wire the RunService subscriptions, ensuring no per-frame
-- dispatch runs before the state machine is ready.
function StateMachine:Initialize()
	RunService.Heartbeat:Connect(function(dt)
		if self._current ~= nil and implements(self._current, "IExecutable") then
			self._current:Execute(dt)
		end
	end)

	RunService.Stepped:Connect(function(_time, dt)
		if self._current ~= nil and implements(self._current, "IFixedExecutable") then
			self._current:FixedExecute(dt)
		end
	end)

	if RunService:IsClient() then
		RunService.RenderStepped:Connect(function(dt)
			if self._current ~= nil and implements(self._current, "ILateExecutable") then
				self._current:LateExecute(dt)
			end
		end)
	end
end

return StateMachine
