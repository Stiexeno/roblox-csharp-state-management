using DependencyInjection;

namespace StateManagement
{
    /// <summary>
    /// Concrete <see cref="IStateMachine"/>. Holds the active state, dispatches
    /// per-frame ticks to <see cref="IExecutable"/> / <see cref="IFixedExecutable"/>
    /// / <see cref="ILateExecutable"/>, and instantiates new states via the
    /// injected <see cref="IStateFactory"/>.
    ///
    /// Owns no RunService connections: the DI container drives the tick
    /// interfaces after <c>Container.Bootstrap()</c> (client: RenderStepped →
    /// Tick, Heartbeat → LateTick; server: Heartbeat → Tick then LateTick;
    /// both: Stepped → FixedTick).
    /// </summary>
    public class StateMachine : IStateMachine, ITickable, IFixedTickable, ILateTickable
    {
        public StateMachine(IStateFactory factory) { }

        public void Enter<TState>() where TState : IState { }

        /// <summary>Container-driven. Dispatches the active state's <see cref="IExecutable.Execute"/>.</summary>
        public void Tick(double dt) { }

        /// <summary>Container-driven. Dispatches the active state's <see cref="IFixedExecutable.FixedExecute"/>.</summary>
        public void FixedTick(double dt) { }

        /// <summary>Container-driven. Dispatches the active state's <see cref="ILateExecutable.LateExecute"/>.</summary>
        public void LateTick(double dt) { }

        /// <summary>
        /// Exits the current state and drops any queued transitions. The
        /// container's tick dispatch no-ops while no state is active;
        /// <see cref="IStateMachine.Enter{TState}"/> starts the machine again.
        /// </summary>
        public void Stop() { }
    }
}
