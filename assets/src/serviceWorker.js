const isLocalhost = Boolean( window.location.hostname === 'localhost' );

export function register(config) {
    const swUrl = `/service-worker.js`;
    return navigator.serviceWorker.register(swUrl)
    .then((registration) => {
        return registration.pushManager.getSubscription()
            .then(async function(subscription) {
                if (subscription) {
                    return subscription;
                } else {
                    return subscribe(registration);
                }
            })
            .then(register_subscription)
            .catch(function(thing){
                console.log("unable to register service worker")
                console.log(thing)
            });
    });
}

async function subscribe(registration){
    const response = await fetch('./vapidPublicKey');
    const vapidPublicKey = await response.text();
    const convertedVapidKey = urlBase64ToUint8Array(vapidPublicKey);

    return registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: convertedVapidKey
    })
}

function register_subscription(subscription){
    fetch('/registersubscription', {
        method: 'post',
        headers: {
          'Content-type': 'application/json'
        },
        body: JSON.stringify({
          subscription: subscription
        }),
      });
    return subscription;
}

function registerValidSW(swUrl, config) {
      console.error('Error during service worker registration:', error);
}

function checkValidServiceWorker(swUrl, config) {
  fetch(swUrl)
    .then(response => {
      const contentType = response.headers.get('content-type');
      if (
        response.status === 404 ||
        (contentType != null && contentType.indexOf('javascript') === -1)
      ) {
        // No service worker found. Probably a different app. Reload the page.
        navigator.serviceWorker.ready.then(registration => {
          registration.unregister().then(() => {
            window.location.reload();
          });
        });
      } else {
        // Service worker found. Proceed as normal.
        registerValidSW(swUrl, config);
      }
    })
    .catch(() => {
      console.log(
        'No internet connection found. App is running in offline mode.'
      );
    });
}

export function unregister() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.ready.then(registration => {
      registration.unregister();
    });
  }
} 

function urlBase64ToUint8Array(base64String) {
  var padding = '='.repeat((4 - base64String.length % 4) % 4);
  var base64 = (base64String + padding)
    .replace(/\-/g, '+')
    .replace(/_/g, '/');
 
  var rawData = window.atob(base64);
  var outputArray = new Uint8Array(rawData.length);
 
  for (var i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}
