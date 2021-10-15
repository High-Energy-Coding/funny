import './main.css';
import * as serviceWorker from './serviceWorker'

import 'phoenix_html';

serviceWorker.register();

window.trigger_login_loading = () => {
    document.querySelector(".spinny").classList.add("yes-spinny")
    document.querySelector(".spinner-center").classList.add("yes-gray")
}
