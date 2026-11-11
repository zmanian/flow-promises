# Quint for flow promises

Start from `example/`. It is a small onboarding flow with three promises, and one of them breaks. `example/mocks/index.html` is its design surface. Run the check to see the report and render the chart:

```sh
<skill dir>/scripts/check example/onboarding.qnt --view example/view.mts --out DIR
```

## Shape

- Give the screen a sum type, such as `type Screen = Welcome | Profile | Home`. Keep what changes a screen without moving the user, such as a save in flight, in its own variable.
- Write `controls(...)` as a `pure def` that gives the controls each mock frame shows. Guard each user action on its control, through a `pure def` such as `shows("Skip", screen, saving)`.
- Write one action for each thing the user does and for each thing the world does, and list them all in `step` with `any`.
- Give each variable few values. Bound counters and lists with a small maximum, because TLC visits every state.

## Promises

Write each promise as a `val` when it must hold in every state, and as a `temporal` when it is about how a run goes on. Put the reader's sentence above it as a `///` doc comment. In the config, list each `val` as an `INVARIANT` and each `temporal` as a `PROPERTY`.

| The reader says | Write |
|---|---|
| You can skip from every onboarding screen. | `val SkipAlwaysShown = inOnboarding(screen) implies shows("Skip", screen, saving)` |
| You never see "Saved" while the save is still going. | `val SavedMeansSaved = screen == Saved implies not(saving)` |
| What you typed is never lost. | `val DraftKept = draft != "" implies (shownDraft == draft or storedDraft == draft)` |
| Once you reach Home, onboarding never pulls you back. | `temporal HomeIsFinal = always(screen == Home implies always(screen == Home))` |
| If you keep pressing Skip, you reach Home. | `temporal YouCanAlwaysFinish = weakFair(YouPressSkip, vars) implies eventually(screen == Home)` |
| If you keep pressing Save and the network works, you get past Profile. | `temporal SaveGoesThrough = (weakFair(YouPressSave, vars) and strongFair(TheSaveSucceeds, vars)) implies always(screen == Profile implies eventually(screen != Profile))` |

Write `val vars = (screen, saving, profileSaved)` with every variable.

- Quint has no `ENABLED`. So a promise about what the user can do checks what the screen shows, and the guard on each action ties the action to its control.
- A screen with no step out breaks `NoDeadlock`. You get this check without writing it. Follow [the statechart guide](../statechart/GUIDE.md) for real end states.
- "The user is never stuck" needs the reader to say what the user keeps doing. TLC cannot check "from each screen, some path reaches Home". Write "if you keep pressing X, you reach Y" with `weakFair` on the user's action. The chart shows the other ways out.
- Add fairness on a world action, such as `TheSaveSucceeds`, only when the promise says so, such as "when the network works". Without it, the world may fail forever, which is the case the reader often forgets.
- Use `strongFair` for an action that turns on and off over and over, such as `TheSaveSucceeds`, which goes away each time the save fails and comes back when you retry. With `weakFair`, the save can fail forever.

## Gotchas

- Name the main module after the file. `check` compiles the module named like `FLOW.qnt`.
- The config uses `INIT q_init` and `NEXT q_step`.
- TLC names each step after the action that holds its primed assignments. Write the assignments in each action's own body. When actions share a helper action, every step gets the helper's name.
- In the view, a sum type value is an object with one key, its tag, such as `{ Home: { tag: "UNIT" } }`. A record is an object. `example/view.mts` has a `tag()` helper.
- In a repo whose `package.json` does not set `"type": "module"`, a `.ts` view does not load. Name the view `.mts`.
- `quint run --invariant NAME FLOW.qnt` tries random runs fast. Use it while you write the model. Only `check` gives the verdict.
