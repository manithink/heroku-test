function javascript_load()  {

  var pull    = $('#pull');
  menu    = $('nav ul');
  menuHeight  = menu.height();

  $(pull).on('click', function(e) {
    e.preventDefault();
    menu.slideToggle();
  });

  $(window).resize(function(){
        var w = $(window).width();
        if(w > 320 && menu.is(':hidden')) {
          menu.removeAttr('style');
        }
    });
      

  $(".close").on('click', function(e){
    e.preventDefault();
    $(".close").parent().fadeOut();
  });

  setTimeout(function(){ $('.flash.close').parent().fadeOut() }, 3000);


}

$(function(){
  javascript_load();

    $("#mobile_pcg_edit_cancel,#mobile_pcg_breadcrum,#pcg_change_password_cancel").on('click', function( event ) {
    var link = $(this).attr('href');
    event.preventDefault();
    jConfirm('Do you really want to leave this page ? (Unsaved changes will be lost)','Confirmation', function(c){
      if(c){
          var self = $(this)
          window.location = link;
      }
      else{
          console.log("cancel")
      }
    });
  });
})
