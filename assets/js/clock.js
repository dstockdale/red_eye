var months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

function updateClock(elementId) {
  var dt = new Date();

  var h = dt.getUTCHours().toString();
  h = h.length == 1 ? "0" + h : h;

  var m = dt.getUTCMinutes().toString();
  m = m.length == 1 ? "0" + m : m;

  var s = dt.getUTCSeconds().toString();
  s = s.length == 1 ? "0" + s : s;

  var month = dt.getUTCMonth() + 1;

  var result =
    dt.getUTCFullYear() +
    "-" +
    month +
    "-" +
    dt.getUTCDate() +
    " " +
    h +
    ":" +
    m +
    ":" +
    s;
  document.getElementById(elementId).textContent = result;

  setTimeout(updateClock.bind(this, elementId), 100);
}

window.addEventListener("DOMContentLoaded", function (e) {
  updateClock("date_time");
});
