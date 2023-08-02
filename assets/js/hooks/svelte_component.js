import { SvelteComponents } from "../svelte/index";

function getProps(props) {
  if (!props) return {};

  return JSON.parse(props);
}

const SvelteComponent = {
  mounted() {
    const name = this.el.dataset.name;
    const el = this.el;
    const props = getProps(this.el.dataset.props);
    const component = SvelteComponents[name];
    console.log(props);
    new component({ target: el, props: props });
  },
};

export { SvelteComponent };
