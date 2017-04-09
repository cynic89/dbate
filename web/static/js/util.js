var Util = function(){
  return{
    Toast: toast,
    url: url
  }
}

var toast = {
  show : function(message, time){
    document.getElementById("toast-text").innerHTML = message;
    $("#div-toast").show();
    setTimeout(function () {
    $("#div-toast").hide();
    }, time);
  }
}

var url = function(){
  var url ;
  if(parent != window){
    var referrer = document.referrer;
    var url = document.createElement('a');
    url.href = referrer;
  }
  else{
    url = window.location;
  }
  return url;
}
export default Util()
