namespace StateManagement
{
    /// <summary>
    /// Called once when the state machine transitions into this state.
    /// </summary>
    public interface IEnter
    {
        void Enter();
    }
}
