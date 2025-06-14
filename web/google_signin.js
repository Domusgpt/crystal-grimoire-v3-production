// Google Sign-In configuration for web
window.onload = function() {
  // Initialize Google Sign-In
  if (typeof gapi !== 'undefined') {
    gapi.load('auth2', function() {
      gapi.auth2.init({
        client_id: '437420484025-your-web-client-id.apps.googleusercontent.com'
      });
    });
  }
};