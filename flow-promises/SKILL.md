---
name: flow-promises
description: "Design a product flow before code exists: hi-fi mocks of each screen, a Quint model of how the user and the world move between them, and promises in the product's words, such as 'you can always skip onboarding', checked by TLC. Each broken promise comes back as a path through the mocks, and the flow changes until each promise holds. The mocks, model, and chart go into the repo as the seed for the build. Use for /flow-promises, or to settle the edge cases of a new feature, flow, or re-architecture before you build it."
disable-model-invocation: true
---

# Flow promises

Design the flow before you build it. The mocks show what the user sees. A Quint model says how the user and the world move the flow between those screens. The promises say what the flow guarantees, in words that the reader can judge without the model. TLC checks each promise, and a broken promise comes back as a path that you play through the mocks.

The reader is the person who owns the product decision. The reader agrees to each promise and picks each fix.

## 1. Draw out the flow

Ask the reader for the goal, each way in, each way out, and what the user can lose. Then list what can happen without the user: a request that succeeds, fails, or hangs, a timer, another device or user, the app closing. Most edge cases come from this list. Settle the scope before you mock, and follow [experience first](references/experience-first.md) on tradeoffs.

## 2. Mock each screen

Make a hi-fi mock of each screen the user can see, including loading, saving, error, empty, and offline. Use the project's design system, its components, and real copy. Put the frames on one design surface: a canvas in the design tool that the team uses, or, when it has none, one HTML page at `mocks/index.html` beside the flow. [`references/example/mocks/index.html`](references/example/mocks/index.html) shows the layout.

- Title each frame with its chart label, the label that the view's `state()` returns.
- Each frame shows only the controls that the model's `controls()` gives for it, in the same words.
- Show the rendered chart beside the frames, so that the reader sees both at once. On an HTML page, show `../FLOW.svg` in an `img` that stays in view while the frames scroll. In a design tool, place `FLOW.svg` as an image beside the frames. The first check fills this place.
- When you change the mocks or the model, change the other one in the same round.

Show the mocks to the reader before you write promises. A wrong screen costs less to fix now.

## 3. Model the flow

Read [`references/quint.md`](references/quint.md), and start from [`references/example/`](references/example/). The model has a variable for each thing the user sees, each stored value, and each request in flight. It has one action for each thing the user does and each thing the world does. Name each action as a sentence, such as `YouPressSkip` or `TheSaveFails`.

Keep the model as accurate as the flow. Never change the model to fit the chart: do not limit where a world action can happen, fold two actions into one, add a `CONSTRAINT`, or drop a variable only to bring the state count under the chart budget in [the statechart guide](statechart/GUIDE.md). A model with thousands of states is fine. To draw it, merge for rendering only, as step 5 says.

## 4. Propose promises

Propose the promises that the flow needs, such as "you can skip onboarding from every screen" or "a save that ends after you leave never moves you". Show the reader the list before you check any of them: each promise in the reader's words, and what it rules out. Then stop and wait. The reader keeps, changes, or drops each one, and picks which ones to prove. Do not write a promise into the model or the config, or check it, until the reader picks it. Then write each picked promise in Quint with the reader's sentence above it, and list it in the config.

Never weaken a promise to make it hold. Only the reader changes a promise.

## 5. Check

Run:

```sh
<skill dir>/scripts/check FLOW.qnt [--config FILE] [--view FILE] [--out DIR]
```

The command compiles the Quint model to TLA+ and runs the bundled statechart checker ([guide](statechart/GUIDE.md)) on it. Then it renders the chart with Pele in the colors from [`statechart/references/render.md`](statechart/references/render.md), and writes `FLOW.mmd` and `FLOW.svg` beside the flow. An HTML surface picks up the new chart when you reload it. In a design tool, replace the chart image after each check. Never draw or edit the chart by hand. Follow [the statechart guide](statechart/GUIDE.md) for the view, end states, chart size, and the report. When the checker draws no chart, or draws only the bug paths because the model has more than 500 states, keep the model as it is and draw a merged chart for the design surface:

1. Run TLC on the full model with `-dump dot,actionlabels`, so that it writes every state and step.
2. Give each state the label of a render-only view. The render view starts from the check's view and merges labels that the reader can read as one state, such as every screen that you reach while a recording still runs. Merge steps the same way, by their labels.
3. Draw one chart state for each label and one arrow for each pair of labels that a step joins, and render it with `scripts/render.mjs`.

The merged chart keeps every model state and step. It only draws fewer of them. Name each merge in the README and in the hand-off. The check and its report still run on the full model. The first run downloads Quint and Pele, and needs the network and Java 21 or later. When Java on `PATH` is older, the command uses mise.

## 6. Fix the flow from each counterexample

For each broken promise:

1. Play its path through the mocks on the design surface: the frames in path order, with the step label between each two frames. The chart beside it marks the same path.
2. Decide what broke it:
   - The model allows a step that the mocks do not. Fix the model.
   - The flow has a hole. Draw two or three fixes as changed frames, and say what each costs the user. For a save that ends after you skip, you can hide Skip while it saves, cancel the save on Skip, or finish the save in the background and stay on Home. The reader picks one.
   - The promise asks for the wrong thing. The reader rewrites it. Write down why.
3. Change the mocks and the model together, and check again. A fix can break a different promise, so check them all.

Repeat until each promise holds, or until the reader accepts a break. Write down each accepted break with its path.

## 7. Check in the seed

Put these where the team keeps design docs, by default `docs/flows/FLOW/`:

- `FLOW.qnt`, `FLOW.cfg`, and the view
- `FLOW.mmd` and `FLOW.svg` from the last check
- the mocks, with the chart on the design surface
- `README.md` with each promise in the reader's words and whether it holds, each design change that a path caused with that path, what the model leaves out, and the command that checks it again

Leave out the rest of the `--out` folder.

## Hand off

Give the reader the design surface, and one line for each promise. For the build, each promise becomes an acceptance test, and each path that changed the design becomes a test that replays it, one step for each action. When the code exists, replay the paths as [the statechart guide](statechart/GUIDE.md) says. To keep a model in step with the code, use `create-formal-verification-skill` from [pstack](https://github.com/bkase/plugins/tree/6f35f6ae6b3581c499bdfcae080932b4ffa7e281/pstack/skills/create-formal-verification-skill) (optional, not bundled).
