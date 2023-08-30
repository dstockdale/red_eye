<script>
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

  const period = {
    timeFrom: { day: 1, month: 1, year: 2018 },
    timeTo: { day: 1, month: 1, year: 2019 },
  };

  // let debounceTimer;
  // const debounce = (callback, time) => {
  //   window.clearTimeout(debounceTimer);
  //   debounceTimer = window.setTimeout(callback, time);
  // }

  export let data;
  export let context;
  // let data = generateBarsData(period);

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

    context.pushEvent("candle:bars-info", barsInfo);
    console.log(barsInfo);
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

  function getBusinessDayBeforeCurrentAt(date, daysDelta) {
    const dateWithDelta = new Date(
      Date.UTC(date.year, date.month - 1, date.day - daysDelta, 0, 0, 0, 0)
    );
    return {
      year: dateWithDelta.getFullYear(),
      month: dateWithDelta.getMonth() + 1,
      day: dateWithDelta.getDate(),
    };
  }

  function generateBarsData(period) {
    const res = [];
    const controlPoints = generateControlPoints(res, period);
    for (let i = 0; i < controlPoints.length - 1; i++) {
      const left = controlPoints[i];
      const right = controlPoints[i + 1];
      fillBarsSegment(left, right, res);
    }
    return res;
  }

  function fillBarsSegment(left, right, points) {
    const deltaY = right.price - left.price;
    const deltaX = right.index - left.index;
    const angle = deltaY / deltaX;
    for (let i = left.index; i <= right.index; i++) {
      const basePrice = left.price + (i - left.index) * angle;
      const openNoise = 0.1 - Math.random() * 0.2 + 1;
      const closeNoise = 0.1 - Math.random() * 0.2 + 1;
      const open = basePrice * openNoise;
      const close = basePrice * closeNoise;
      const high = Math.max(basePrice * (1 + Math.random() * 0.2), open, close);
      const low = Math.min(basePrice * (1 - Math.random() * 0.2), open, close);
      points[i].open = open;
      points[i].high = high;
      points[i].low = low;
      points[i].close = close;
    }
  }

  function generateControlPoints(res, period, dataMultiplier) {
    let time =
      period !== undefined ? period.timeFrom : { day: 1, month: 1, year: 2018 };
    const timeTo =
      period !== undefined ? period.timeTo : { day: 1, month: 1, year: 2019 };
    const days = getDiffDays(time, timeTo);
    dataMultiplier = dataMultiplier || 1;
    const controlPoints = [];
    controlPoints.push({ index: 0, price: getRandomPrice() * dataMultiplier });
    for (let i = 0; i < days; i++) {
      if (i > 0 && i < days - 1 && Math.random() < 0.05) {
        controlPoints.push({
          index: i,
          price: getRandomPrice() * dataMultiplier,
        });
      }
      res.push({ time: time });
      time = nextBusinessDay(time);
    }
    controlPoints.push({
      index: res.length - 1,
      price: getRandomPrice() * dataMultiplier,
    });
    return controlPoints;
  }

  function getDiffDays(dateFrom, dateTo) {
    const df = convertBusinessDayToUTCTimestamp(dateFrom);
    const dt = convertBusinessDayToUTCTimestamp(dateTo);
    const diffTime = Math.abs(dt.getTime() - df.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  function convertBusinessDayToUTCTimestamp(date) {
    return new Date(Date.UTC(date.year, date.month - 1, date.day, 0, 0, 0, 0));
  }

  function nextBusinessDay(time) {
    const d = convertBusinessDayToUTCTimestamp({
      year: time.year,
      month: time.month,
      day: time.day + 1,
    });
    return {
      year: d.getUTCFullYear(),
      month: d.getUTCMonth() + 1,
      day: d.getUTCDate(),
    };
  }

  function getRandomPrice() {
    return 10 + Math.round(Math.random() * 10000) / 100;
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
