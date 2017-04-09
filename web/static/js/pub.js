import Constants from './const'
var pub = angular.module("naradPub",[]);

pub.value("baseUrl",Constants.rootUrl);

pub.controller("mainCtrl",["$scope", "$http", "baseUrl", function($scope, $http, baseUrl ){
  $scope.reqSubmitted = false;
  $scope.pubRequest ={hosts: []};
    $scope.pendingResp = false;

  $scope.submitRequest = function(form){
    console.log("inside submit Request")
    $scope.pendingResp = true;
    if($scope.pubRequest.host)
    $scope.pubRequest.hosts.push($scope.pubRequest.host)
    if($scope.pubRequest.altHost && $scope.pubRequest.altHost!="")
    $scope.pubRequest.hosts.push($scope.pubRequest.altHost)
    //password
    $scope.pubRequest.secret = $scope.pubRequest.password
    $scope.pubRequest.password = "";
    $scope.pubRequest.confPassword = "";

    $scope.pubRequest.phone = "+"+$scope.pubRequest.ext+"  "+$scope.pubRequest.phoneNum+"";
    $http.post(baseUrl+"api/pub/submit", $scope.pubRequest).success(function(response){
      alert("Request Submitted successfully. We will contact you for verification ASAP")
      $scope.pubRequest ={};
      $scope.altHost="";
      $scope.host="";
      $scope.pubRequest.hosts=[];
      form.$setPristine();
      form.$setUntouched();
      $scope.reqSubmitted = true;
      $scope.pendingResp = false;
      $("#regLink").trigger('click')
    }).error(function(error){
      $scope.pubRequest.hosts=[];
      alert("Oops, something went wrong. Please try again.");
      $scope.pendingResp = false;
    })
  }
}]);
pub.controller("pubCtrl",["$scope", "$http", "baseUrl", function($scope, $http, baseUrl ){
    $scope.topics=[];
    $scope.posts = [];
    $scope.getTopics = function(){
      $http.post(baseUrl+"api/pub/topics/",$scope.pub).success(function(topics){
        if(topics && topics.length>0){
          $scope.topics = topics;
          $scope.error = ""
        }else{
          $scope.error = "No topic found for this publisher"
        }

      }).error(function(e){
          $scope.error = e
      })
    }

    $scope.getPosts = function(topic){
      $http.get(baseUrl + 'api/posts/topic?' + 'publisher=' + $scope.pub.id + '&topic=' + topic ).success(function(posts){
        if(posts && posts.length>0){
          $scope.posts = posts;
          $scope.error = ""
        }else{
          $scope.error = "No post found for this publisher"
        }

      }).error(function(e){
          $scope.error = "Error while fetching post for topic"
      })
    }

    $scope.removePost = function(post){
      $http.post(baseUrl + 'api/posts/remove', post).success(function(response){
        alert("Post Deleted Successfully");
        post.is_active = false
      }).error(function(e){
          alert("Error While Deleting post")
      })
    }
}])
var compareTo = function() {
return {
    require: "ngModel",
    scope: {
        otherModelValue: "=compareTo"
    },
    link: function(scope, element, attributes, ngModel) {

        ngModel.$validators.compareTo = function(modelValue,viewValue) {

            var matcher = modelValue || viewValue;
            return matcher == scope.otherModelValue;
        };

        scope.$watch(function(){return scope.otherModelValue}, function() {
            ngModel.$validate();
        });
    }
};
};
pub.directive("compareTo", compareTo);
