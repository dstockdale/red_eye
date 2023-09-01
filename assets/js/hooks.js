import { LiveSelect } from "./hooks/live_select";
import { Clippy } from "./hooks/clippy";
import { Toaster } from "./hooks/toaster";
import { Darkness } from "./hooks/darkness";
import { getHooks } from "live_svelte";
import * as Components from "../svelte/**/*.svelte";

const SvelteHook = getHooks(Components);

let Hooks = {
  LiveSelect: LiveSelect,
  Clippy: Clippy,
  Toaster: Toaster,
  Darkness: Darkness,
  ...SvelteHook,
};

export default Hooks;
