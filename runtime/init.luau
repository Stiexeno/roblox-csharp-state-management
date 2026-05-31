-- Entry point for the StateManagement plugin. Exports the public
-- surface — StateMachine + StateFactory — for direct require by
-- user code that wants to subclass them. The lifecycle marker
-- interfaces (IState / IEnter / IExit / IExecutable /
-- IFixedExecutable / ILateExecutable / IStateMachine /
-- IStateFactory) have no Luau artifact; they lower to string names
-- at every reference site, so there's nothing to import for them.

return {
	StateMachine = require(script.StateMachine),
	StateFactory = require(script.StateFactory),
}
