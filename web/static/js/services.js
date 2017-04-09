import {
  Socket
}
from "deps/phoenix/web/static/js/phoenix"
import "./fb"
import Util from "./util"

import dbate from './dbate'

dbate.factory('User', function() {
  var savedUser = {};

  function get() {
    return savedUser;
  }

  function set(user) {
    savedUser = user;
  }
  return {
    get: get,
    set: set
  }
})

dbate.factory('socketService', ['User', function(User) {
  var socket = {};

  function init(params) {
    socket = new Socket("/socket", {
      params: {
        current_user: User.get(),
        host: params.host
      }
    });
    socket.connect();
    socket.onError(() => console.log("there was an error with the connection!"))
    socket.onClose(() => console.log("the connection dropped"))
    return socket;
  }

  function get() {
    return socket
  }

  return {
    get: get,
    init: init
  }
}])

dbate.factory('fbLogin', ['User', '$http', 'LoginService', function(User, $http,
  LoginService) {
  window.checkLoginState = function() {
    FB.login(function(response) {
      statusChangeCallback(response);
    });
  }

  function statusChangeCallback(response) {
    if (response.status === 'connected') {
      LoginService.login("fb", response.authResponse.accessToken)
    } else if (response.status === 'not_authorized') {
      document.getElementById('login-error').innerHTML = "Please login to this app"
    } else {
      console.log('Not logged into facebook');
      document.getElementById('login-error').innerHTML = "Please login to this facebook"
    }
  }
  return {
    init: 'init'
  }
}])

dbate.factory('googleLogin', ['User', '$http', 'LoginService', function(User, $http,
  LoginService) {
  window.onSignIn = function(response) {
    LoginService.login("google", response.hg.id_token);
  }

  var auth2;
  var startApp = function() {
    gapi.load('auth2', function() {
      // Retrieve the singleton for the GoogleAuth library and set up the client.
      auth2 = gapi.auth2.init({
        client_id: '486302302918-ng3vlnk8h0jvr5j8ccl6cun9pbqlmh0u.apps.googleusercontent.com',
        cookiepolicy: 'single_host_origin',
        // Request scopes in addition to 'profile' and 'email'
        //scope: 'additional_scope'
      });
      attachSignin(document.getElementById('googleSignInBtn'));
    });
  }();

  function attachSignin(element) {
    auth2.attachClickHandler(element, {},
      function(response) {
        LoginService.login("google", response.hg.id_token);
      },
      function(error) {
        document.getElementById('login-error').innerHTML = "Error while logging in. Please try again."
      });
  }



  return {
    init: 'init'
  }
}])



dbate.service('LoginService', ['$http', 'baseUrl', 'User',
  function($http, baseUrl, User) {

    function login(nw, accessToken) {
      $http({
        method: 'POST',
        url: baseUrl + '/api/users/login/',
        data: {
          nw: nw,
          accessToken: accessToken
        }
      }).then(function successCallback(response) {
        if (response.data.id) {
          User.set(response.data);
          document.getElementById('modal-exit-btn').click();
          Util.Toast.show("Logged in successfully",4000);
        }

      }, function errorCallback(response) {
        document.getElementById('login-error').innerHTML = "Error while logging in. Please try again" ;
        Util.Toast.show("Oops, something went wrong",4000);
      });
    }

    function logoff() {
      $http({
        method: 'POST',
        url: baseUrl + '/api/users/logoff/',
        data: {}
      }).then(function successCallback(response) {
          User.set({});
      }, function errorCallback(response) {
        console.log("Error while logoff " + response);
      });
    }
    return {
      login: login,
      logoff: logoff
    }

  }
])

dbate.service('PostService', ['$http', 'baseUrl', function($http, baseUrl) {
  var pgPosts = [];
  var weight = 0;
  var cutoff;

  function fetch(publisher, topic, page) {
    var critCutoff = "";
    if(cutoff && page>1){
      critCutoff = '&cutoff=' + cutoff
    }
    $http.defaults.headers.common['cutoff'] = cutoff
    $http({
      method: 'GET',
      url: baseUrl + 'api/posts/show?' + 'publisher=' + publisher + '&topic=' +
        topic + '&page=' + page + critCutoff
    }).then(function successCallback(response) {
      if(page==1 && response.data && response.data.length>0){
        cutoff = response.data[0].created_at
      }
      pgPosts = response.data;
    }, function errorCallback(response) {
      console.log("Error while loading posts " + response);
    });
  }

  function findWeight(publisher, topic) {
    $http({
      method: 'GET',
      url: baseUrl + 'api/posts/weight?' + 'publisher=' + publisher + '&topic=' + topic
    }).then(function successCallback(response) {
      weight = response.data;
      console.log("Weighed ")
    }, function errorCallback(response) {
      console.log("Error while loading weight " + response);
    });
  }

  function clear(){
    pgPosts = [];
  }

  function pagePosts() {
    return pgPosts
  }

  function getWeight() {
    return weight;
  }

  function setWeight(newWeight) {
    weight = newWeight
  }

  return {
    fetch: fetch,
    pagePosts: pagePosts,
    findWeight: findWeight,
    getWeight: getWeight,
    setWeight: setWeight,
    clear: clear
  }

}])
