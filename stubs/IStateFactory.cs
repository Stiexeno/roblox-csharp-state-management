namespace StateManagement
{
    // Resolves a state class to an instance, typically via the DI
    // container. Indirection through this interface lets test code
    // swap in a stub factory that returns canned states without
    // depending on a full Container setup.
    public interface IStateFactory
    {
        TState Create<TState>() where TState : IState;
    }
}
