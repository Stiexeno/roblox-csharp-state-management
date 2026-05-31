using DependencyInjection;

namespace StateManagement
{
    // Default IStateFactory implementation. Delegates to IInstantiator
    // so states don't need their own Bind line — the instantiator
    // constructs each state with DI-resolved ctor args on demand,
    // returning a fresh instance every Create call (states are
    // transient: re-entering a state means a new instance).
    //
    // Bind in your installer alongside the state machine itself:
    //
    //     Container.BindInterfacesTo<StateFactory>().AsSingle();
    //     Container.BindInterfacesTo<GameStateMachine>().AsSingle();
    //
    // The C# body is empty — the Lua runtime under
    // ReplicatedStorage.Plugins.StateManagement.StateFactory provides
    // the actual resolve loop. This stub exists for IDE typechecking.
    public class StateFactory : IStateFactory
    {
        public StateFactory(IInstantiator instantiator) { }

        public TState Create<TState>() where TState : IState => default;
    }
}
