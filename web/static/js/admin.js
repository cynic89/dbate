import Constants from './const'
var admin = angular.module("admin",[]);

admin.run(['$http', function($http){

    $http.defaults.headers.common['Authorization'] = 'Basic ' + document.getElementById('ba_cred').value;
}])

admin.value("baseUrl",Constants.rootUrl+"admin/");

admin.controller("mainCtrl",["$scope", "$http", "baseUrl", function($scope, $http, baseUrl ){
  $scope.pubRequests = [];
  $scope.page=0;
  $scope.pendingResp = false;
  $scope.msg="";
  $scope.lastPage = false;

  $scope.getPubReqs = function(){
    var page = $scope.page+1;
    $scope.pendingResp = true;
    $http.get(baseUrl+"api/pubreqs?page="+page).success(function(response){
      $scope.pendingResp = false;
      if(response && response.length>0){
      Array.prototype.push.apply($scope.pubRequests,response)
        $scope.page = $scope.page+1;
        $scope.lastPage = false;
    }
    else{
      $scope.lastPage = true;
      $scope.msg = "You have reached the last page"
    }
    }).error(function(error){
      alert("Error While getting requests");
      $scope.pendingResp = false;
    })
  }
  $scope.getPubReqs($scope.page);

  $scope.more = function(){
    $scope.getPubReqs($scope.page);
  }

  $scope.approve = function(pubreq){
    $scope.pendingResp = true;
    $http.post(baseUrl+"api/approve", pubreq).success(function(response){
      alert("Request approved successfully");
      pubreq.status = "Approved";
      pubreq.pub_id = response.pub_id;
      $scope.pendingResp = false;
    }).error(function(error){
      alert("Error While submitting request");
        $scope.pendingResp = false;
    })
  }

}])

export default admin
