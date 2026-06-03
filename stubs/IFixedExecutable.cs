namespace StateManagement
{
    /// <summary>
    /// Fixed-timestep tick for the active state, driven by <c>RunService.Stepped</c>
    /// (physics phase).
    /// </summary>
    public interface IFixedExecutable
    {
        void FixedExecute(double dt);
    }
}
