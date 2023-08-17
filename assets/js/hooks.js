import { LiveSelect } from "./hooks/live_select";
import { Clippy } from "./hooks/clippy";
import { Toaster } from "./hooks/toaster";
import { Darkness } from "./hooks/darkness";
import { Chart } from "./hooks/chart";
import { LiveReact } from "./hooks/live_react";
import { SvelteComponent } from "./hooks/svelte_component";

let Hooks = {};

Hooks.LiveSelect = LiveSelect;
Hooks.Clippy = Clippy;
Hooks.Toaster = Toaster;
Hooks.Darkness = Darkness;
Hooks.Chart = Chart;
Hooks.LiveReact = LiveReact;
Hooks.SvelteComponent = SvelteComponent;

export default Hooks;
