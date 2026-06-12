-- Base state machine. The user's GameStateMachine subclass inherits
-- from this; binding via `BindInterfacesTo<GameStateMachine>().AsSingle()`
-- registers the machine under every interface it implements
-- (IStateMachine + IInitializable, plus the user's own IGameStateMachine
-- if they added one).
--
-- Lifecycle interfaces are name-checked against each state's
-- `__interfaces` table (compiler-emitted) so adding or removing a
-- hook just means adding / removing an interface implementation on
-- the state class — no separate registration. The walk runs once per
-- transition; the resulting booleans are cached on `_currentFlags`
-- and the per-frame handlers only read the cache.
--
-- Per-frame dispatch is driven by RunService, mapped per side so every
-- hook fires everywhere and Execute is the pre-frame tick:
--   IExecutable       → RenderStepped on the client, Heartbeat on the
--                       server (RenderStepped doesn't exist there)
--   IFixedExecutable  → RunService.Stepped (server + client, pre-physics)
--   ILateExecutable   → RunService.Heartbeat (server + client). The
--                       Roblox frame runs RenderStepped → Stepped →
--                       physics → Heartbeat, so this is genuinely
--                       "late" on the client; on the server Execute
--                       and LateExecute share one Heartbeat connection
--                       with Execute dispatched first.

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
	self._currentFlags = nil
	self._transitioning = false
	self._queue = {}
	self._connections = {}
	self._initialized = false
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

-- One interface walk per transition; everything downstream reads
-- these booleans instead of re-walking the chain every frame.
local function computeFlags(instance)
	local interfaces = collectInterfaces(instance)
	return {
		enter = interfaces["IEnter"] == true,
		exit = interfaces["IExit"] == true,
		executable = interfaces["IExecutable"] == true,
		fixedExecutable = interfaces["IFixedExecutable"] == true,
		lateExecutable = interfaces["ILateExecutable"] == true,
	}
end

-- `Enter(nil)` or a non-class argument would otherwise error deep
-- inside the DI `__ctorParams` walk — catch it here with a message
-- that names what was actually passed.
local function assertStateClass(stateClass)
	if stateClass == nil then
		error("StateMachine:Enter — state class is nil", 3)
	end
	if type(stateClass) ~= "table" or type(rawget(stateClass, "new")) ~= "function" then
		error("StateMachine:Enter — expected a state class, got "
			.. typeof(stateClass) .. " (" .. tostring(stateClass) .. ")", 3)
	end
end

-- Runs one transition:
--   1. Current state's Exit (if it has one) — pcall'd; an error is
--      warned but never aborts the swap, so the machine can't wedge
--      with ticks firing on an exited state.
--   2. Construct the new state via the factory (DI-resolved) —
--      pcall'd too; on failure the machine settles on no current
--      state rather than half a transition.
--   3. Swap current + cache its lifecycle flags.
--   4. New state's Enter (if it has one) — pcall'd, warned.
function StateMachine:_performTransition(stateClass)
	local outgoing = self._current
	if outgoing ~= nil and self._currentFlags.exit then
		local ok, err = pcall(outgoing.Exit, outgoing)
		if not ok then
			warn("StateMachine: " .. tostring(getmetatable(outgoing)) .. ":Exit() errored: " .. tostring(err))
		end
	end
	self._current = nil
	self._currentFlags = nil

	local ok, result = pcall(self._factory.Create, self._factory, stateClass)
	if not ok then
		warn("StateMachine: failed to construct state " .. tostring(stateClass) .. ": " .. tostring(result))
		return
	end
	self._current = result
	self._currentFlags = computeFlags(result)

	if self._currentFlags.enter then
		local okEnter, err = pcall(result.Enter, result)
		if not okEnter then
			warn("StateMachine: " .. tostring(stateClass) .. ":Enter() errored: " .. tostring(err))
		end
	end
end

-- `Enter<TState>()` lowers to `Enter(stateClass)` — stateClass is
-- the C# type's table.
--
-- Re-entrancy: calling Enter from inside a state's Exit()/Enter()
-- doesn't nest. The request is queued (FIFO — requests apply in the
-- order they were made) and processed iteratively after the current
-- transition completes, so no state is ever orphaned without its
-- Exit and no exit path runs twice.
function StateMachine:Enter(stateClass)
	assertStateClass(stateClass)
	if self._transitioning then
		table.insert(self._queue, stateClass)
		return
	end
	self._transitioning = true
	self:_performTransition(stateClass)
	while #self._queue > 0 do
		self:_performTransition(table.remove(self._queue, 1))
	end
	self._transitioning = false
end

-- IInitializable hook. Container.Bootstrap() instantiates singletons
-- bound under IInitializable and fires Initialize() — this is when
-- we wire the RunService subscriptions, ensuring no per-frame
-- dispatch runs before the state machine is ready. Calling it a
-- second time is a warned no-op so subscriptions can't double.
function StateMachine:Initialize()
	if self._initialized then
		warn("StateMachine: Initialize() called twice — ignoring")
		return
	end
	self._initialized = true

	if RunService:IsClient() then
		table.insert(self._connections, RunService.RenderStepped:Connect(function(dt)
			self:_dispatchExecute(dt)
		end))
		table.insert(self._connections, RunService.Heartbeat:Connect(function(dt)
			self:_dispatchLateExecute(dt)
		end))
	else
		table.insert(self._connections, RunService.Heartbeat:Connect(function(dt)
			self:_dispatchExecute(dt)
			self:_dispatchLateExecute(dt)
		end))
	end

	table.insert(self._connections, RunService.Stepped:Connect(function(_time, dt)
		local current = self._current
		if current ~= nil and self._currentFlags.fixedExecutable then
			current:FixedExecute(dt)
		end
	end))
end

function StateMachine:_dispatchExecute(dt)
	local current = self._current
	if current ~= nil and self._currentFlags.executable then
		current:Execute(dt)
	end
end

function StateMachine:_dispatchLateExecute(dt)
	local current = self._current
	if current ~= nil and self._currentFlags.lateExecutable then
		current:LateExecute(dt)
	end
end

-- Teardown: disconnects every tick subscription, exits the current
-- state (pcall'd, like any transition), drops any queued transitions
-- and clears current. Initialize() may be called again afterwards.
function StateMachine:Stop()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	table.clear(self._connections)
	self._initialized = false
	table.clear(self._queue)

	local current = self._current
	if current ~= nil and self._currentFlags.exit then
		local ok, err = pcall(current.Exit, current)
		if not ok then
			warn("StateMachine: " .. tostring(getmetatable(current)) .. ":Exit() errored: " .. tostring(err))
		end
	end
	self._current = nil
	self._currentFlags = nil
end

return StateMachine
