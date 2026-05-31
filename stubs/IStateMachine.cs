namespace StateManagement
{
    // State machine surface that callers depend on. Transition is via
    // a single generic method — `Enter<NextState>()` — keyed by the
    // state's C# type. The implementation resolves the state through
    // IStateFactory, runs the outgoing state's Exit (if it implements
    // IExit), swaps current, then runs the incoming state's Enter
    // (if it implements IEnter).
    public interface IStateMachine
    {
        void Enter<TState>() where TState : IState;
    }
}
