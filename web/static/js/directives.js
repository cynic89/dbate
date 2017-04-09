import dbate from './dbate'

dbate.directive('post',function() {
    return {
        restrict: 'E',
        scope: false,
        template: "<div ng-include ='template(post)'> </div>"
    }
});

dbate.directive('stance',function(){
  return{
    restrict: 'E',
    link: function(scope,element,attrs){
      var button = angular.element('<button type="button" class="btn btn-sm  btn-stance" style="text-align: center"> </button> ');

      scope.$watch(attrs.curr, function(value) {
        if(attrs.type == scope.stance){
        button.removeClass('btn-'+attrs.type);
        button.addClass('btn-stance-selected');
        span.addClass('txt-stance-selected');
      }
      else{
        button.addClass('btn-'+attrs.type);
        button.removeClass('btn-stance-selected');
        span.removeClass('txt-stance-selected');

      }
    });

      if('equi' == attrs.type){
        button.addClass('btn-txt-stance');
      }

      if(attrs.btnImg){
        var img = angular.element('<img class="btn-stance-img">');
        img.attr('src', attrs.btnImg);
        button.append(img);
      }

      if(attrs.btnText){
        button.text(attrs.btnText);
      }

      if(attrs.btnIcon){
        var icon = angular.element("<i class='"+attrs.btnIcon+"'></i>");
        button.append(icon);
      }

      element.append(button);

      if(attrs.btnHint){
        var span =  angular.element('<span class="txt-stance"></span>');
        span.html(attrs.btnHint);
        element.append('<br>')
        element.append(span);
      }

      element.on('click', function(){
        scope.userPost.stance = attrs.type;
        scope.stance = attrs.type;
        scope.$apply();
      })
    }
}
})

dbate.directive('contenteditable', ['$sce', function($sce) {
  return {
    restrict: 'A', // only activate on element attribute
    require: '?ngModel', // get a hold of NgModelController
    link: function(scope, element, attrs, ngModel) {
      if (!ngModel) return; // do nothing if no ng-model

      // Specify how UI should be updated
      ngModel.$render = function() {
        element.html($sce.getTrustedHtml(ngModel.$viewValue || ''));
      };

      // Listen for change events to enable binding
      element.on('blur keyup change', function() {
        scope.$evalAsync(read);
      });
      read(); // initialize

      // Write data to the model
      function read() {
        var html = element.text();
        // When we clear the content editable the browser leaves a <br> behind
        // If strip-br attribute is provided then we strip this out
        if ( attrs.stripBr && html == '<br>' ) {
          html = '';
        }
        ngModel.$setViewValue(html);
      }
    }
  };
}]);
