
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '853033511461753',
      xfbml      : true,
      version    : 'v2.5'
    });
  };

  (function(d, s, id){
     var js, fjs = d.getElementsByTagName(s)[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement(s); js.id = id;
     js.src = "//connect.facebook.net/en_US/sdk.js";
     fjs.parentNode.insertBefore(js, fjs);
   }(document, 'script', 'facebook-jssdk'));




    
 // Here we run a very simple test of the Graph API after login is
 // successful.  See statusChangeCallback() for when this call is made.
 function testAPI() {
   console.log('Welcome!  Fetching your information.... ');
   FB.api('/me', function(response) {
     console.log('Successful login for: ' + JSON.stringify(response));
     document.getElementById('status').innerHTML =
       'Thanks for logging in, ' + response.name + '!';
   });
 }
