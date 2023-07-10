const isDark = () => {
  return localStorage.getItem("darkMode") === "on";
};

const setDarkMode = (value) => {
  storeDarkMode(value);
  setDarkClass(value);
};

const storeDarkMode = (value) => {
  localStorage.setItem("darkMode", value);
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
      console.log(this.el);
    });
  },
};

export { isDark, Darkness };
