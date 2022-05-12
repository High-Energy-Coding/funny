import "@babel/polyfill";
import './main.css';
import * as serviceWorker from './serviceWorker'

import 'phoenix_html';

serviceWorker.register();

window.trigger_login_loading = () => {
    document.querySelector(".spinny").classList.add("yes-spinny")
    document.querySelector(".spinner-center").classList.add("yes-gray")
}

function confirm_notifications() {
  if (Notification.permission !== 'granted' ) {
    Notification.requestPermission(function (permission) {
      // If the user accepts, let's create a notification
      if (permission === "granted") {
        var notification = new Notification("Yay. Notifications set to come your way soon");
      }
    });
  }
}

window.addEventListener('load', (event) => {
    confirm_notifications()
    lazy_load_images()
});


function lazy_load_images(){
    const lazyImages = document.querySelectorAll(
      ".js-lazy-load, img[data-src]",
    );

    const lazyImageObserver = new IntersectionObserver(
      //eslint-disable-next-line
      function (entries, observer) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            const lazyImage = entry.target;
            if (lazyImage.dataset.src) {
              lazyImage.src = lazyImage.dataset.src;
            }
            if (lazyImage.dataset.style) {
              lazyImage.style = lazyImage.dataset.style;
            }
            lazyImage.classList.remove("js-lazy-load");
            lazyImage.classList.remove("styles-lazy-load");
            lazyImageObserver.unobserve(lazyImage);
          }
        });
      },
      { rootMargin: "16px", threshold: 0.05 },
    );

    lazyImages.forEach(function (lazyImage) {
      lazyImageObserver.observe(lazyImage);

      lazyImage.addEventListener("error", (event) => {
        addClass(event.srcElement, "bad-image");
      });
    });
  }

