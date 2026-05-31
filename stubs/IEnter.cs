namespace StateManagement
{
    // Optional lifecycle hook. Called once when the state becomes
    // active — after the previous state's Exit but before any per-frame
    // dispatch. Skip the interface entirely on states that don't need
    // entry setup; the state machine never invokes a missing method.
    public interface IEnter
    {
        void Enter();
    }
}
