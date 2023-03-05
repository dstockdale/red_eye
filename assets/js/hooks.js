import { createChart, CrosshairMode } from "lightweight-charts";

let Hooks = {};

Hooks.CandleStickChart = {
  mounted() {
    const data = JSON.parse(this.el.dataset.chartData);
    const volumeData = data.map((d) => {
      return { value: d.volume, time: d.time };
    });
    const chart = createChart(this.el, {
      crosshair: {
        mode: CrosshairMode.Normal,
      },
    });
    const candleSeries = chart.addCandlestickSeries({
      scaleMargins: {
        // positioning the price scale for the area series
        top: 0.1,
        bottom: 0.4,
      },
    });
    // const volumeSeries = chart.addHistogramSeries({
    //   color: "#26a69a",
    //   priceFormat: {
    //     type: "volume",
    //   },
    //   priceScaleId: "", // set as an overlay by setting a blank priceScaleId
    //   scaleMargins: {
    //     top: 0.7, // highest point of the series will be 70% away from the top
    //     bottom: 0,
    //   },
    // });
    // volumeSeries.priceScale().applyOptions({
    //   scaleMargins: {
    //     top: 0.7, // highest point of the series will be 70% away from the top
    //     bottom: 0,
    //   },
    // });

    candleSeries.setData(data);
    // volumeSeries.setData(volumeData);
    chart.timeScale().fitContent();
  },
};

export default Hooks;
