import { NiceChart } from "../solid_charts/index";
// import { createSignal } from "solid-js";
import { render } from "solid-js/web";

const SolidChart = {
  mounted() {
    render(() => <NiceChart />, this.el);
  },

  // destroyed() {
  //   const { target } = this;
  //   unmountComponentAtNode(target);
  // },
};

export { SolidChart };
