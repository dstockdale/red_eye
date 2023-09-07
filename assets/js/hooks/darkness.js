const isDark = () => {
  if (typeof window == "undefined" || typeof localStorage == "undefined") {
    return false;
  }
  return localStorage.getItem("darkMode") === "on";
};

const setDarkMode = (value) => {
  storeDarkMode(value);
  setDarkClass(value);
};

const subscribeDarkMode = (fn) => {
  if (typeof document == "undefined") {
    return;
  }
  document.addEventListener("dark-mode-change", function (event) {
    fn.apply(undefined, [event.detail]);
  });
};

const storeDarkMode = (value) => {
  localStorage.setItem("darkMode", value);
  const event = new CustomEvent("dark-mode-change", {
    bubbles: true,
    detail: { value: value },
  });
  document.dispatchEvent(event);
};

const setDarkClass = (value) => {
  const root = document.documentElement;

  if (value == "on") {
    root.classList.add("dark");
  } else {
    root.classList.remove("dark");
  }
};

const toggleDarkMode = () => {
  const currentValue = isDark();
  const value = toggledValue(currentValue);
  setDarkMode(value);
};

const toggledValue = (value) => {
  return value ? "off" : "on";
};

const Darkness = {
  mounted() {
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      toggleDarkMode();
    });
  },
};

export { isDark, Darkness, subscribeDarkMode };
