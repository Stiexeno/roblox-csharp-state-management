namespace StateManagement
{
    // Per-frame tick driven by RunService.RenderStepped (fires once
    // per render frame BEFORE rendering, CLIENT-ONLY — the state
    // machine silently skips the subscription on the server context).
    // Use for camera, UI, post-physics visual smoothing. The dt arg
    // is the upcoming render delta.
    public interface ILateExecutable
    {
        void LateExecute(double dt);
    }
}
