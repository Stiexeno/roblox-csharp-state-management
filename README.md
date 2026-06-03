# roblox-csharp-state-management

A pure-C# state machine packaged as a [roblox-csharp](https://github.com/Stiexeno/roblox-csharp) plugin. States are normal classes; lifecycle is opt-in via marker interfaces; everything wires through [roblox-csharp-dependency-injection](https://github.com/Stiexeno/roblox-csharp-dependency-injection).

## Install

From your roblox-csharp project root:

```sh
roblox-csharp plugin add Stiexeno/roblox-csharp-dependency-injection
roblox-csharp plugin add Stiexeno/roblox-csharp-state-management
```

Both plugins land under `plugins/`; the runtime mounts at `ReplicatedStorage.Plugins.StateManagement`.

## Quick start

```csharp
using DependencyInjection;
using StateManagement;

public class BootstrapState : IState, IEnter
{
    public void Enter() { /* spin up services */ }
}

public class GameplayState : IState, IEnter, IExecutable
{
    public void Enter() { /* attach systems */ }
    public void Execute(double dt) { /* per-frame tick */ }
}

public class GameInstaller : ServerInstaller
{
    public GameInstaller(Container container) : base(container) { }

    public override void InstallBindings()
    {
        Container.Bind<IStateFactory>().To<StateFactory>().AsSingle();
        Container.BindInterfacesTo<StateMachine>().AsSingle();

        Container.Bind<BootstrapState>().AsTransient();
        Container.Bind<GameplayState>().AsTransient();
    }
}
```

Inject `IStateMachine` somewhere and call `machine.Enter<BootstrapState>()` to start.

## API surface

### Marker

| Type | Purpose |
|---|---|
| `IState` | Marks a class as a transition target. Combine with the lifecycle interfaces below. |

### Lifecycle (opt-in)

| Interface | Method | When |
|---|---|---|
| `IEnter` | `Enter()` | Once on transition into the state. |
| `IExit` | `Exit()` | Once on transition out. |
| `IExecutable` | `Execute(double dt)` | Per-frame, `RunService.Heartbeat`. |
| `IFixedExecutable` | `FixedExecute(double dt)` | Fixed timestep, `RunService.Stepped`. |
| `ILateExecutable` | `LateExecute(double dt)` | After render, `RunService.RenderStepped`. |

States only pay for the ticks they implement — no virtual dispatch overhead on states that don't care.

### Driver

| Type | Purpose |
|---|---|
| `IStateMachine` / `StateMachine` | Holds the active state, drives ticks, exits and enters on `Enter<T>()`. |
| `IStateFactory` / `StateFactory` | Resolves states through the DI container's `IInstantiator` so constructor params get injected. |

## What's not in v1

- **State stacks / history.** Single active state only. Push/pop semantics deferred until a real use case.
- **Transition guards.** No `CanEnter` hook; the caller decides.
- **Async `Enter` / `Exit`.** Roblox doesn't have a native async-state concept; if you need async setup, kick off a task inside `Enter` and gate on a flag inside `Execute`.

## License

[MIT](LICENSE).
