(function() {

  $(function() {
    return $(document).bind('page:change', function() {
      return $('form[data-validate]').validate();
    });
  });

}).call(this);