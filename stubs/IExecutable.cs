namespace StateManagement
{
    // Per-frame tick driven by RunService.Heartbeat (fires once per
    // frame on BOTH server and client AFTER physics simulation). The
    // dt arg is seconds-since-last-frame. Implement on states that
    // need general-purpose update logic; for physics-coupled work use
    // IFixedExecutable instead.
    public interface IExecutable
    {
        void Execute(double dt);
    }
}
