import { LiveSelect } from "./hooks/live_select";
import { CandleStickChart } from "./hooks/candle_stick_chart";
import { Clippy } from "./hooks/clippy";
import { Toaster } from "./hooks/toaster";
import { Darkness } from "./hooks/darkness";

let Hooks = {};

Hooks.LiveSelect = LiveSelect;
Hooks.CandleStickChart = CandleStickChart;
Hooks.Clippy = Clippy;
Hooks.Toaster = Toaster;
Hooks.Darkness = Darkness;

export default Hooks;
