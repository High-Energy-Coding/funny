
self.addEventListener('push', function(event) {
    console.log("HI")
    data = event.data.json()
  
  // Keep the service worker alive until the notification is created.
  event.waitUntil(
    self.registration.showNotification('Funny App', {
      body:  data.name + ' made a joke',
      action: data.link,
    })
  );
});

