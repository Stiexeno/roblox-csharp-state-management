using DependencyInjection;

namespace StateManagement
{
    /// <summary>
    /// Concrete <see cref="IStateMachine"/>. Holds the active state, dispatches
    /// per-frame ticks to <see cref="IExecutable"/> / <see cref="IFixedExecutable"/>
    /// / <see cref="ILateExecutable"/>, and instantiates new states via the
    /// injected <see cref="IStateFactory"/>.
    /// </summary>
    public class StateMachine : IStateMachine, IInitializable
    {
        public StateMachine(IStateFactory factory) { }

        public void Enter<TState>() where TState : IState { }

        /// <summary>
        /// Wires RunService tick callbacks. Subclass and call <c>base.Initialize()</c>
        /// to extend.
        /// </summary>
        public virtual void Initialize() { }
    }
}
