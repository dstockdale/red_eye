import { App } from "../charts/index";
import { createRoot, unmountComponentAtNode } from "react-dom/client";
import React from "react";

const Chart = {
  mounted() {
    const root = createRoot(this.el);
    root.render(<App />);
  },

  destroyed() {
    const { target } = this;
    unmountComponentAtNode(target);
  },
};

export { Chart };
