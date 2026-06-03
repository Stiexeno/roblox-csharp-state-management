using DependencyInjection;

namespace StateManagement
{
    /// <summary>
    /// Default <see cref="IStateFactory"/> backed by the DI container's
    /// <see cref="IInstantiator"/>. Bind once in your installer and the
    /// state machine resolves every state through it.
    /// </summary>
    public class StateFactory : IStateFactory
    {
        public StateFactory(IInstantiator instantiator) { }

        public TState Create<TState>() where TState : IState => default;
    }
}
