$(function(){


  $( "#new_user" ).submit(function( event ) {
    if ($("#login_email").val() == '') {
      $("#login_error").html("<p>Enter your email</p>");
      event.preventDefault();
    }
    else if ( !isValidEmailAddress( $("#login_email").val() ) ){
      $("#login_error").html("<p>Enter valid email</p>");
      event.preventDefault();
    }
    else if ($("#user_password").val() == '') {
      $("#login_error").html("<p>Enter your password</p>");
      event.preventDefault();
    }
  });

  $( ".password_reset" ).submit(function( event ) {
    if ( $("#user_email").val() != '' ){

      if ( !isValidEmailAddress( $("#user_email").val() ) ){
        $("#login_error").html("<p>Email not valid</p>");
        event.preventDefault();
      }
    }
  });

  $(".status_change a").on('click', function( event ) {
    var link = $(this).attr('href');
    var link_array = link.split("/");
    var len = link_array.length;
    var msg;
    if (link_array[len-1] == "Active"){
      msg = 'This will remove all future appointments, Do you really want to change this status?';
    }
    else{
      msg = 'Do you really want to change this status?';
    }
    event.preventDefault();
    jConfirm(msg,'Confirmation', function(c){
      if(c){
          var self = $(this)
          window.location = link;
      }
      else{
          console.log("cancel")
      }
    });

  });

  $(".last-td a").on('click', function( event ) {
    var link = $(this).attr('href');
    event.preventDefault();
    jConfirm('Do you really want to delete this record ?','Confirmation', function(c){
      if(c){
          var self = $(this)
          window.location = link;
      }
      else{
          console.log("cancel")
      }
    });

  });

  $(".coming_soon").on('click', function( event ) {
    event.preventDefault();
    jConfirm('This page is under construction, coming soon','Information', function(c){
      if(c){
          var self = $(this)
          window.location = link;
      }
      else{
          console.log("cancel")
      }
    });

  });


  $("#pcgc_new_cancel, #pcgc_breadcrum_link, #pcgc_edit_breadcrum_link").on('click', function( event ) {
    // var link = $(this).attr('href');
    event.preventDefault();
    jConfirm('Do you really want to leave this page ? (Unsaved changes will be lost)','Confirmation', function(c){
      if(c){
          var self = $(this)
          window.location = "/admin/home";
      }
      else{
          console.log("cancel")
      }
    });

  });

  $("#pcgc_edit_cancel, #pcgc_edit_view_breadcrum_link, #pcga_invite_cancel, #pcg_invite_cancel").on('click', function( event ) {
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


  $("#pcg_new_cancel, #pcg_breadcrum_link, #pcg_edit_breadcrum_link, #fcg_breadcrum_home_link, #fcg_edit_breadcrum_link, pcg_invite_cancel").on('click', function( event ) {
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


  $("#pcg_edit_cancel, #pcg_edit_view_breadcrum_link").on('click', function( event ) {
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

  $("#pcgc_settings_edit_cancel").on('click', function( event ) {
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

  $("#fcg_new_cancel, #fcg_breadcrum_link, #fcg_edit_breadcrum_link").on('click', function( event ) {
    // var link = $(this).attr('href');
    event.preventDefault();
    jConfirm('Do you really want to leave this page ? (Unsaved changes will be lost)','Confirmation', function(c){
      if(c){
          var self = $(this)
          window.location = "/fcg/view_care_clients";
      }
      else{
          console.log("cancel")
      }
    });

  });




  // $('.farCare-tble td a').click( function (event) {
  //   $.getScript(this.href);
  //   return false;
  //   event.preventDefault();
  // });



  function isValidEmailAddress(emailAddress) {
    var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
    console.log(pattern.test(emailAddress));
    return pattern.test(emailAddress);
  }

  $(".back_to_home").on('click',function(e){
    var link = $(this).attr('href');

    e.preventDefault();
    jConfirm("Do you really want to goto admin home?", "Confirmation", function(c){
      if(c){
        window.location = link
      }
    });
  });


  $(".flash.close").on('click', function(e){
      e.preventDefault();
      $(".close").parent().fadeOut();
  });

  setTimeout(function(){ $('.flash.close').parent().fadeOut(); }, 3000);


// $(document).ready(javascript_load)
// $(document).on('page:load', javascript_load)



})

