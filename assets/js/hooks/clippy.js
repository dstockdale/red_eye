import { notification } from "./toaster";

const selectText = (el) => {
  if (document.selection) {
    var range = document.body.createTextRange();
    range.moveToElementText(el);
    range.select();
  } else if (window.getSelection) {
    var range = document.createRange();
    range.selectNode(el);
    window.getSelection().addRange(range);
  }
};

const Clippy = {
  mounted() {
    const { from } = this.el.dataset;
    const elem = document.getElementById(from);
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      notification("Copied to clipboard!");

      navigator.clipboard.writeText(elem.innerText).then(() => {
        selectText(elem);
      });
    });
  },
};

export { Clippy };
