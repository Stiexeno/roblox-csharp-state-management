namespace StateManagement
{
    /// <summary>
    /// Per-frame tick for the active state, driven by <c>RunService.Heartbeat</c>.
    /// </summary>
    public interface IExecutable
    {
        void Execute(double dt);
    }
}
