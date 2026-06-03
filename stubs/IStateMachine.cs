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
        /// invoking the matching lifecycle callbacks.
        /// </summary>
        void Enter<TState>() where TState : IState;
    }
}
