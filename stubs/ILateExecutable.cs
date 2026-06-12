namespace StateManagement
{
    /// <summary>
    /// Late tick for the active state, driven by <c>RunService.RenderStepped</c>.
    /// Fires before the frame renders — use for camera + UI follow-ups that
    /// must land in the same frame.
    /// </summary>
    public interface ILateExecutable
    {
        void LateExecute(double dt);
    }
}
