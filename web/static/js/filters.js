import dbate from './dbate'

dbate.filter('dateFormat', function(){
  return function(input){

    var normalizedTxt = "";
    var normalizingFactor = 1;
    var currDate = new Date();
    var inputDate = new Date(input);
    var diffInSeconds = (currDate - inputDate)/1000;


    if(diffInSeconds < 20){
      return "Just now"
    }

    else if(diffInSeconds < 60){
      normalizedTxt = "seconds";
    }
    else if (diffInSeconds < 3600) {
      normalizedTxt = "minutes";
      normalizingFactor = 60;
    }

    else if(diffInSeconds < 86400){
      normalizedTxt = "hours";
        normalizingFactor = 60 * 60;
    }

    else if(diffInSeconds < (86400 * 30)){
      normalizedTxt = "days"
        normalizingFactor = 60 * 60 * 24;
    }

    else if(diffInSeconds < (86400 * 30 * 365)){
        normalizedTxt = "months"
        normalizingFactor = 60 * 60 * 24 * 30;
    }

    var formttedDate = (Math.round(diffInSeconds/normalizingFactor)) + " " + normalizedTxt + " " + "ago"

    return formttedDate
  }
})


dbate.filter('imgUrlReset', function(){
  return function(input){
    if(input){
      console.log("input is "+input)
      return input;
    }
    else{
      console.log("returning default value")
      return "http:"
    }
  }
})
