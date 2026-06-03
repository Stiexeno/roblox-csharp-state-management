namespace StateManagement
{
    /// <summary>
    /// Called once when the state machine transitions out of this state.
    /// </summary>
    public interface IExit
    {
        void Exit();
    }
}
