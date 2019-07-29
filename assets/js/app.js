// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

document.addEventListener("DOMContentLoaded", () => {
  const toggles = document.querySelectorAll("[data-js-toggle]");
  toggles.forEach(toggle => {
    const target = document.querySelector(toggle.dataset.jsToggle);
    toggle.addEventListener("click", () => {
      target.classList.toggle("_active");
    });
  })
});
