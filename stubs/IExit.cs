namespace StateManagement
{
    // Optional lifecycle hook. Called once when the state is leaving —
    // before the next state's Enter, and after the last per-frame
    // dispatch. Use it to tear down subscriptions / pooled resources
    // that don't survive the transition.
    public interface IExit
    {
        void Exit();
    }
}
