$(function() {

  $("a.care_cliet_popup").hover(function(e) {
      e.preventDefault();
      loading(); // loading
      self = $(this)
      setTimeout(function(){ // then show popup, deley in .5 second
        loadPopup(self); // function show popup
      }, 500); // .5 second
      return false;
    });

  $(".close").click(function() {
    disablePopup();  // function close pop up
  });

  $(this).keyup(function(event) {
    if (event.which == 27) { // 27 is 'Ecs' in the keyboard
      disablePopup();  // function close pop up
    }
  });

  $("div#backgroundPopup").click(function() {
    disablePopup();  // function close pop up
  });

  function loading() {
    $("div.loader").show();
  }

  function closeloading() {
    $("div.loader").fadeOut('normal');
  }

  var popupStatus = 0; // set value

  function loadPopup(self) {
    var id_name = self.attr('id');
    if(popupStatus == 0) { // if value is 0, show popup
      closeloading(); // fadeout loading
      $("div."+id_name).fadeIn(500); // fadein popup div
      $("#backgroundPopup").css("opacity", "0.7"); // css opacity, supports IE7, IE8
      $("#backgroundPopup").fadeIn(0001);
      popupStatus = 1; // and set value to 1
    }
  }
  function disablePopup() {
    if(popupStatus == 1) { // if value is 1, close popup
      $("#care-clients").fadeOut("normal");
      $(".farCare-popup").fadeOut("normal");
      $("#backgroundPopup").fadeOut("normal");
      popupStatus = 0;  // and set value to 0
    }
  }
  
});