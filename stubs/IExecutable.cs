namespace StateManagement
{
    /// <summary>
    /// Per-frame tick for the active state. Client: <c>RunService.RenderStepped</c>
    /// (pre-frame). Server: <c>RunService.Heartbeat</c> (RenderStepped doesn't
    /// exist there).
    /// </summary>
    public interface IExecutable
    {
        void Execute(double dt);
    }
}
