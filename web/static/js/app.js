  import "deps/phoenix_html/web/static/js/phoenix_html"

  import {
    Socket
  }
  from "deps/phoenix/web/static/js/phoenix"

  import dbate from './dbate'
  import './services'
  import './directives'
  import './filters'
  import Util from './util'
  import './admin'
  import './pub'

  var maxPostLen = 150
  dbate.controller("mainCtrl", ['$scope', '$timeout','$rootScope', 'socketService', 'User', 'PostService', 'LoginService',
    function($scope, $timeout, $rootScope, socketService, User, PostService, LoginService) {

      var url = Util.url();
      $scope.parHost = url.host;
      $scope.parPathName = url.pathname;
      $scope.parProtocol = url.protocol;

      $scope.posts = [];
      $scope.socket = {};
      $scope.channel = {};
      $scope.user = {};
      $scope.angle = {};
      $scope.dbate = {page: 0};
      $scope.balanceImg = "images/ws_equal.gif"
      $scope.lastPage = false;

      $scope.maxPostLength = maxPostLen;

      $scope.user.id = document.getElementById('userIdSvr').value
      $scope.pubId = document.getElementById('pubId').value

      if ($scope.user.id != 'undefined') {
        LoginService.login('fb', 'asas');
      }

      $scope.isUserLoggedIn = function() {
        return !(User.get().id == undefined || User.get().id == "undefined")
      }

      $scope.$watch($scope.isUserLoggedIn, function(v) {

        $scope.dbate.page = 1;
        $scope.posts = [];


        PostService.fetch($scope.pubId, $scope.parPathName, $scope.dbate.page);

        if (typeof $scope.socket.disconnect == "function") {
          // console.log("disconnecting previous socket")
          $scope.socket.disconnect();
        }
        $scope.socket = socketService.init({
          host: $scope.parHost
        });

        var room = "dbate:" + $scope.pubId + ":" + $scope.parPathName;
        $scope.channel = $scope.socket.channel(room, {
          host: $scope.parProtocol+'//' + $scope.parHost
        })
        $scope.channel.join()
          .receive("ok", resp => {
            console.log("Joined successfully for user", User.get().id)
          })
          .receive("error", resp => {
            console.log("Unable to join", resp);
            Util.Toast.show("There was a problem joining the room. Messages may not be recieved or sent properly.\n" +
              " Please refresh the page.", 5000);
          })

        $scope.channel.on("new_post", msg => {
          $scope.posts.unshift(msg);
          $scope.$apply();
        });

        $scope.channel.on("weight_changed", msg => {
          PostService.setWeight(msg.weight);
          $scope.$apply();
        });

        $scope.channel.on("vote", msg => {
          angular.forEach($scope.posts, function(p) {
            if (msg.id == p.id) {
              if (p.votes) {
                p.votes++;
              } else {
                p.votes = 1;
              }
            }
          });
          $scope.$apply();
        });
        $scope.user = User.get();
      })

      $scope.postsLoaded = function() {
        return PostService.pagePosts();
      }

      $scope.$watch($scope.postsLoaded, function(pagePosts) {
        if (pagePosts && pagePosts.length>0) {
          if ($scope.dbate.page == 1) {
            $scope.posts = [];
          }
          Array.prototype.push.apply($scope.posts, pagePosts)

        }
        else{
          if ($scope.dbate.page > 1) {
          console.log('last page reached');
          $scope.lastPage = true;
          $scope.dbate.page = $scope.dbate.page-1;
        }
        }
      })

      PostService.findWeight($scope.pubId , $scope.parPathName);
      $scope.weightChanged = function() {
        return PostService.getWeight();
      }
      $scope.$watch($scope.weightChanged, function(weight) {
        $scope.balanceImg = getImgForWeight(weight);
      })

    }
  ])

  dbate.controller("userCtrl", ['$scope', 'User', 'socketService', 'fbLogin', 'googleLogin', 'LoginService',
    function($scope, User, socketService, fbLogin, googleLogin, LoginService) {
      $scope.stance = '';
      $scope.allowPost = function() {
        return $scope.isUserLoggedIn() && $scope.isPostValid();
      }

      $scope.isPostValid = function() {
        if ($scope.userPost) {
          if ($scope.userPost.body) {
            var body = $scope.userPost.body.replace(/&nbsp;/g, ' ');
            if (body.trim().length > 0 && body.trim().length<=$scope.maxPostLength) {
              return true;
            }
          }
        }
        return false;
      }


      $scope.send = function() {
        if ($scope.userPost.stance == undefined) {
          Util.Toast.show("Choose your STANCE. It can be 'For', 'Against' or 'Neutral'", 5000);
          return;
        }
        $scope.channel.push("new_post", $scope.userPost, 10000)
          .receive("ok", (msg) => {console.log("created message", msg), $scope.userPost.body = ""})
          .receive("error", (reasons) => {
            if ('unauthorized' == reasons) {
              Util.Toast.show("You are not logged in. Please login. The button is on the top right corner, if you are lazy to look arounf !!!", 2000);
            } else {
              Util.Toast.show("OOPS, Something went wrong. Don't worry, we are looking at the logs", 2000);
            }
          })
          .receive("timeout", () => {
            Util.Toast.show("Seems to be a networking issue. I would suggest a page refresh !!!", 2000);
          })
      }

      $scope.logoff = function() {
        LoginService.logoff();
      }

      $scope.getImageUrl = function() {
        if (User.get().image_url) {
          return User.get().image_url;
        }
        return "images/kb_warrior.png";
      }

    }
  ])
  dbate.controller("postsCtrl", ['$scope', '$timeout', 'PostService', function($scope, $timeout, PostService) {

    $scope.vote = function(post) {
      $scope.channel.push("vote", {
          post: post
        }, 10000)
        .receive("ok", (msg) => {
          post.voted = true;
          $scope.$apply();
        })
        .receive("error", (reasons) => {
          if ('Unauthorized' == reasons.reason) {
            Util.Toast.show("You are not logged in. Please login. \nThe button is on the top right corner, if you are lazy to look around !!!",
              4000);
          } else {
            Util.Toast.show("OOPS, Something went wrong. Don't worry, we are looking at the logs\n Reason: " + reasons.reason, 4000);
          }
        })
        .receive("timeout", () => {
          Util.Toast.show("Seems to be a networking issue. I would suggest a page refresh !!!", 4000);
        })
    }

    $scope.template = function(post) {
      var stance = post.stance;
      var templateUrl = "";
      if (stance == 'for') {
        templateUrl = "/partials/for.html"
      } else if (stance == 'against') {
        templateUrl = "/partials/against.html"
      } else {
        templateUrl = "/partials/equi.html"
      }
      return templateUrl;
    }

    $scope.more = function() {
        $scope.dbate.page = $scope.dbate.page+1;
      PostService.fetch($scope.pubId, $scope.parPathName, $scope.$parent.dbate.page);
    }

  }]);

  var maxWt = 16;
  var maxLvl = 8;

  var getImgForWeight = function(weight) {
    var imgLoc = "images/ws/"
    var img = "ws_eq.svg";
    var lvl=0;
    if (weight != undefined) {
      if (weight == 0) {
        img = "ws_eq.svg";
      } else  {
        var modWeight = weight<0 ? weight*-1 : weight;

        for(var i=0; i<maxWt; i=i+(maxWt/maxLvl)){
          if(i>modWeight){
            break;
          }
          lvl++
        }
        if(lvl>maxLvl){
          lvl = maxLvl;
        }
        if(weight<0){
          img="ws_mi_lvl_"+lvl+".svg";
        }
        else{
          img="ws_pl_lvl_"+lvl+".svg";
        }
      }
    }
    return imgLoc+img;
  }
