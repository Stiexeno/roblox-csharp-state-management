namespace StateManagement
{
    // Per-frame tick driven by RunService.Stepped (fires BEFORE physics
    // simulation, both server and client). Use for code that needs to
    // run before Roblox's physics step — joint constraints, force
    // application, character controller input. The dt arg is the
    // upcoming physics delta.
    public interface IFixedExecutable
    {
        void FixedExecute(double dt);
    }
}
