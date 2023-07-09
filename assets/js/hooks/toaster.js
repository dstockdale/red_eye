import Toastify from "toastify-js";

const Toaster = {
  mounted() {
    this.handleEvent("toast", (payload) => {
      console.log("hello");
      console.log(payload);
      const { message } = payload;
      Toastify({
        text: message || "This is a toast",
        className: "info",
      }).showToast();
    });
  },
};

const notification = (
  message,
  opts = { position: "center", className: "info" }
) => {
  const options = Object.assign(
    {
      text: message || "This is a toast",
    },
    opts
  );
  Toastify(options).showToast();
};

export { Toaster, notification };
