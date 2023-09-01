<script>
  import { Series } from "js/charts";
  import { CrosshairMode, ColorType } from "lightweight-charts";
  import {
    Chart,
    CandlestickSeries,
    LineSeries,
    TimeScale,
  } from "svelte-lightweight-charts";

  let timeScale;
  let candleSeries;
  let swingSeries;

  // let debounceTimer;
  // const debounce = (callback, time) => {
  //   window.clearTimeout(debounceTimer);
  //   debounceTimer = window.setTimeout(callback, time);
  // }

  export let data;
  export let live;

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
    live.pushEvent("candle:bars-info", barsInfo);

    live.handleEvent("update-candle", (candle) => {
      mergeCandle(candle);
    });
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

  const options = {
    width: 750,
    height: 400,
    layout: {
      background: {
        type: ColorType.Solid,
        color: "#FFFFFF",
      },
      textColor: "rgba(33, 56, 77, 1)",
    },
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
    timeScale: {
      borderColor: "rgba(197, 203, 206, 1)",
    },
    handleScroll: {
      vertTouchDrag: false,
    },
  };
</script>

<Chart {...options}>
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
    upColor="#089981"
    downColor="#F23645"
    drawWick={true}
    borderColor="#378658"
    borderUpColor="#089981"
    borderDownColor="#F23645"
    wickColor="#B5B5B8"
    wickUpColor="#089981"
    wickDownColor="#F23645"
    barColorsOnPrevClose={false}
  />
</Chart>
