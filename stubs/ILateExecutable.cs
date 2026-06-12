namespace StateManagement
{
    /// <summary>
    /// Late tick for the active state, driven by <c>RunService.Heartbeat</c>
    /// (server + client). The Roblox frame runs RenderStepped → Stepped →
    /// physics → Heartbeat, so this fires after Execute and after physics;
    /// on the server it shares the Heartbeat with Execute, dispatched second.
    /// </summary>
    public interface ILateExecutable
    {
        void LateExecute(double dt);
    }
}
