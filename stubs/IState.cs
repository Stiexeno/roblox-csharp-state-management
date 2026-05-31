namespace StateManagement
{
    // Marker interface every state class implements. Adds no methods on
    // its own — lifecycle behaviour comes from also implementing one or
    // more of IEnter / IExit / IExecutable / IFixedExecutable /
    // ILateExecutable. Without IState the state machine's generic
    // constraint won't compile, so this is the gate that distinguishes
    // a state class from any other DI-bound type.
    public interface IState { }
}
