namespace StateManagement
{
    /// <summary>
    /// Constructs state instances with their dependencies resolved from the
    /// DI container. Override or replace via container binding for custom
    /// instantiation.
    /// </summary>
    public interface IStateFactory
    {
        TState Create<TState>() where TState : IState;
    }
}
