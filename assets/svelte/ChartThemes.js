import { ColorType } from "lightweight-charts";

const THEMES = {
  Dark: {
    chart: {
      layout: {
        background: {
          type: ColorType.Solid,
          color: "rgb(15, 23, 42)",
        },
        lineColor: "#2B2B43",
        textColor: "#94a3b8",
      },
      watermark: {
        color: "rgba(0, 0, 0, 0)",
      },
      crosshair: {
        color: "#758696",
      },
      grid: {
        vertLines: {
          color: "#2B2B43",
        },
        horzLines: {
          color: "#2B2B43",
        },
      },
    },
    series: {
      topColor: "rgba(32, 226, 47, 0.56)",
      bottomColor: "rgba(32, 226, 47, 0.04)",
      lineColor: "rgba(32, 226, 47, 1)",
    },
  },
  Light: {
    chart: {
      layout: {
        background: {
          type: ColorType.Solid,
          color: "#FFFFFF",
        },
        lineColor: "#2B2B43",
        textColor: "#191919",
      },
      watermark: {
        color: "rgba(0, 0, 0, 0)",
      },
      grid: {
        vertLines: {
          visible: false,
        },
        horzLines: {
          color: "#f0f3fa",
        },
      },
    },
    series: {
      topColor: "rgba(33, 150, 243, 0.56)",
      bottomColor: "rgba(33, 150, 243, 0.04)",
      lineColor: "rgba(33, 150, 243, 1)",
    },
  },
};

const AVAILABLE_THEMES = Object.keys(THEMES);

export { THEMES, AVAILABLE_THEMES };
