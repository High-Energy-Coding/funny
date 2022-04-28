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
});

