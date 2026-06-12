# roblox-csharp-state-management

Single-active-state machine for [roblox-csharp](https://github.com/Stiexeno/roblox-csharp). States are plain classes; lifecycle is opt-in via marker interfaces; construction and ticking wire through [roblox-csharp-dependency-injection](https://github.com/Stiexeno/roblox-csharp-dependency-injection).

## Install

```sh
roblox-csharp plugin add Stiexeno/roblox-csharp-dependency-injection
roblox-csharp plugin add Stiexeno/roblox-csharp-state-management
```

The DI plugin is a hard requirement: `StateFactory` resolves states through the container's auto-bound `IInstantiator`, and the machine implements `ITickable` / `IFixedTickable` / `ILateTickable` — the container drives every tick after `Container.Bootstrap()`; the machine owns no RunService connections of its own. Runtime mounts at `ReplicatedStorage.Plugins.StateManagement`.

## Usage

```csharp
using DependencyInjection;
using StateManagement;

public class GameplayState : IState, IEnter, IExecutable, IExit
{
    public void Enter() { }
    public void Execute(double dt) { }
    public void Exit() { }
}

public class GameInstaller : ServerInstaller
{
    public GameInstaller(Container container) : base(container) { }

    public override void InstallBindings()
    {
        Container.Bind<IStateFactory>().To<StateFactory>().AsSingle();
        Container.BindInterfacesTo<StateMachine>().AsSingle();
    }
}
```

Inject `IStateMachine` and call `machine.Enter<GameplayState>()`. States don't need their own bindings — `IInstantiator` constructs them with ctor args resolved from the container.

## API

| Type | Surface |
|---|---|
| `IState` | Marker; required constraint on `Enter<TState>()`. |
| `IEnter` | `Enter()` — once, on transition in. |
| `IExit` | `Exit()` — once, on transition out. |
| `IExecutable` | `Execute(double dt)` — per frame: `RenderStepped` on the client (pre-frame), `Heartbeat` on the server. |
| `IFixedExecutable` | `FixedExecute(double dt)` — physics step, `RunService.Stepped`. |
| `ILateExecutable` | `LateExecute(double dt)` — post-physics, `RunService.Heartbeat` (server + client). On the server it shares the Heartbeat with `Execute`, dispatched second. |
| `IStateMachine` / `StateMachine` | `Enter<TState>()` exits the current state, builds a fresh `TState` via the factory, enters it. `Tick` / `FixedTick` / `LateTick` are container-driven and dispatch the matching state hooks. `Stop()` exits the current state and drops queued transitions; dispatch no-ops until the next `Enter`. |
| `IStateFactory` / `StateFactory` | `Create<TState>()` — transient, DI-constructed state instances. |

## Caveats

- **Ticks don't run until `Container.Bootstrap()`** — the container wires the tick interfaces there, after every `Initialize()`.
- **Transitions during a transition queue.** `Enter<T>()` from inside `Enter()`/`Exit()` doesn't nest — requests queue FIFO and apply after the current transition completes. `Enter()`/`Exit()` errors are warned, never wedge the machine.
- **States are transient.** `Enter<T>()` to the currently active state class exits it and builds a fresh instance.
- Single active state — no stacks, history, guards, or async transitions.

## License

[MIT](LICENSE).
