import { LiveSelect } from "./hooks/live_select";
import { CandleStickChart } from "./hooks/candle_stick_chart";
import { Clippy } from "./hooks/clippy";
import { Toaster } from "./hooks/toaster";

let Hooks = {};

Hooks.LiveSelect = LiveSelect;
Hooks.CandleStickChart = CandleStickChart;
Hooks.Clippy = Clippy;
Hooks.Toaster = Toaster;

export default Hooks;
