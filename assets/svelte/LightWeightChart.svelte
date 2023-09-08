<script>
  import { onMount } from "svelte";
  import { CrosshairMode, ColorType } from "lightweight-charts";
  import {
    Chart,
    CandlestickSeries,
    LineSeries,
    TimeScale,
  } from "svelte-lightweight-charts";
  import { isDark, subscribeDarkMode } from "../js/hooks/darkness";
  import { THEMES, AVAILABLE_THEMES } from "./ChartThemes";

  let timeScale;
  let candleSeries;
  let swingSeries;

  export let data;
  export let swings;
  export let interval;
  export let live;

  let selected = AVAILABLE_THEMES[0];
  $: theme = THEMES[selected];

  function subscribeToEvents() {
    live.handleEvent("update-candle", (candle) => {
      mergeCandle(candle);
    });
  }

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  async function waitForLiveview(cb) {
    while (typeof live?.handleEvent !== "function") {
      await sleep(50);
    }
    cb();
  }

  waitForLiveview(subscribeToEvents);

  function mergeCandle(candle) {
    candleSeries.update(candle);
  }

  let timer = null;

  function handleVisibleLogicalRangeChange() {
    if (!timeScale || !candleSeries) {
      return;
    }
    if (timer !== null) {
      return;
    }
    const logicalRange = timeScale.getVisibleLogicalRange();
    const barsInfo = candleSeries.barsInLogicalRange(logicalRange);

    if (barsInfo.barsBefore <= 10) {
      live.pushEvent("candle:bars-fetch", barsInfo);
    }
  }

  function handleTimeScaleRef(api) {
    timeScale = api;
  }

  function handleSeriesRef(api) {
    candleSeries = api;
  }

  function handleLineSeriesRef(api) {
    swingSeries = api;
  }

  const intervals = {
    "1m": "1 minute",
    "3m": "3 minutes",
    "5m": "5 minutes",
    "15m": "15 minutes",
    "30m": "30 minutes",
    "1h": "1 hour",
    "2h": "2 hours",
    "4h": "4 hours",
    "6h": "6 hours",
    "8h": "8 hours",
    "12h": "12 hours",
    "1d": "1 day",
    "3d": "3 days",
    "1w": "1 week",
    "1M": "1 Month",
  };

  const chartOptions = {
    width: 750,
    height: 400,
    layout: {
      background: {
        type: ColorType.Solid,
        color: "#FFFFFF",
      },
      textColor: "rgba(33, 56, 77, 1)",
    },
    autoSize: true,
    grid: {
      horzLines: {
        color: "#F0F3FA",
      },
      vertLines: {
        color: "#F0F3FA",
      },
    },
    crosshair: {
      mode: CrosshairMode.Normal,
    },
    priceScale: {
      borderVisible: false,
    },
    timeScale: {
      borderVisible: false,
      // borderColor: "rgb(144, 148, 150)",
    },
    handleScroll: {
      vertTouchDrag: false,
    },
  };

  function switchTheme(darkness) {
    selected = darkness.value === "on" ? "Dark" : "Light";
  }

  subscribeDarkMode(switchTheme);

  onMount(() => {
    selected = isDark() ? "Dark" : "Light";
  });
</script>

<div class="inline-flex mb-2 rounded-md shadow-sm isolate" role="group">
  {#each Object.entries(intervals) as [value, _label]}
    <button
      type="button"
      phx-click="set-interval"
      phx-value-interval={value}
      class="{value === interval
        ? 'dark:text-amber-500 text-black bg-gray-100 dark:bg-slate-800 '
        : 'dark:text-zinc-400 text-gray-900 bg-white dark:bg-slate-900 '} relative inline-flex items-center px-3 py-2 -ml-px text-xs font-semibold dark:hover:text-amber-500 hover:text-amber-700 first:rounded-l-md last:rounded-r-md ring-1 ring-inset ring-gray-300 dark:ring-zinc-700 hover:bg-gray-50 dark:hover:bg-slate-800 focus:z-10"
      >{value}</button
    >
  {/each}
</div>

<Chart
  autoSize={true}
  container={{ class: "chart-container" }}
  {...chartOptions}
  {...theme.chart}
>
  <TimeScale
    ref={handleTimeScaleRef}
    on:visibleLogicalRangeChange={handleVisibleLogicalRangeChange}
    timeVisible={true}
    secondsVisible={false}
  />
  <CandlestickSeries
    ref={handleSeriesRef}
    {data}
    reactive={true}
    drawWick={true}
    barColorsOnPrevClose={false}
    {...theme.series}
  />
  <LineSeries
    ref={handleLineSeriesRef}
    data={swings}
    reactive={true}
    priceLineVisible={false}
    lineWidth={2}
    color="orange"
  />
</Chart>

<style>
  :global(.chart-container) {
    aspect-ratio: 16 / 9;
    width: 100%;
    margin: 0 auto 0 0;
  }
</style>
