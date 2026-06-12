namespace StateManagement
{
    /// <summary>
    /// Transitions between <see cref="IState"/> implementations. Inject and call
    /// <see cref="Enter{TState}"/> to drive the machine.
    /// </summary>
    public interface IStateMachine
    {
        /// <summary>
        /// Exits the current state (if any) and enters <typeparamref name="TState"/>,
        /// invoking the matching lifecycle callbacks. Calls made during a transition
        /// are queued (FIFO) and applied after it completes.
        /// </summary>
        void Enter<TState>() where TState : IState;

        /// <summary>
        /// Disconnects all tick subscriptions, exits the current state, and drops
        /// any queued transitions.
        /// </summary>
        void Stop();
    }
}
