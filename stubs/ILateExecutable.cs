namespace StateManagement
{
    /// <summary>
    /// Late tick for the active state, driven by <c>RunService.RenderStepped</c>.
    /// Runs after rendering — use for camera + UI follow-ups.
    /// </summary>
    public interface ILateExecutable
    {
        void LateExecute(double dt);
    }
}
