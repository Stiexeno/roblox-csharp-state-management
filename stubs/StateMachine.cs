using DependencyInjection;

namespace StateManagement
{
    // Base state machine. Subclass to give your machine a domain
    // name and DI binding (Zenject convention from the reference
    // implementation):
    //
    //     public class GameStateMachine : StateMachine, IGameStateMachine
    //     {
    //         public GameStateMachine(IStateFactory factory) : base(factory) { }
    //     }
    //
    //     // installer
    //     Container.BindInterfacesTo<GameStateMachine>().AsSingle();
    //     Container.BindInterfacesTo<StateFactory>().AsSingle();
    //
    // Implements IInitializable so Container.Bootstrap eagerly
    // constructs the machine and wires its RunService subscriptions
    // — without that, ticks never fire.
    //
    // The C# body is empty — the Lua runtime under
    // ReplicatedStorage.Plugins.StateManagement.StateMachine provides
    // the actual transition + per-frame dispatch loop.
    public class StateMachine : IStateMachine, IInitializable
    {
        public StateMachine(IStateFactory factory) { }

        public void Enter<TState>() where TState : IState { }

        // Virtual so subclasses can override to add domain-specific
        // boot steps (typically `base.Initialize()` followed by an
        // initial `Enter<BootState>()`). The base sets up RunService
        // subscriptions — overriders MUST call base or per-frame
        // dispatch never wires.
        public virtual void Initialize() { }
    }
}
