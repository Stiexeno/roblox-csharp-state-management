namespace StateManagement
{
    /// <summary>
    /// Marker for state classes the <see cref="StateMachine"/> can transition into.
    /// Combine with <see cref="IEnter"/>, <see cref="IExit"/>, <see cref="IExecutable"/>,
    /// <see cref="IFixedExecutable"/>, or <see cref="ILateExecutable"/> to opt into
    /// lifecycle callbacks.
    /// </summary>
    public interface IState { }
}
