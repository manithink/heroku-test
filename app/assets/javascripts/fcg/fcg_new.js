$(function() {

  get_states($('#country').val());

  $('#country').change(function(){
    get_states($('#country').val());
    $('#state').next().html('Please select');
  });

  $('#country').focusout(function(){
    validation("#country")
  });
  $('#state').focusout(function(){
    validation("#state")
  });
  $('#time_zone').focusout(function(){
    validation("#time_zone")
  });

  $('.submit').click(function(){
    validation_submit("#country")
    validation_submit("#state")
    validation_submit("#time_zone")
  });

  $("#datepicker").datepicker({
    onClose: function(dateText, inst) { $(inst.input).change().focusout(); },
    changeMonth: true,
    changeYear: true,
    dateFormat: 'dd-mm-yy',
    maxDate : new Date(),
    yearRange: "-100:+0",
    showMonthAfterYear : true
  });

});

function validation(class_name){
  if ($(class_name).val() == ''){
    $(class_name).parent().next().hide();
    $(class_name).parent().next().next().remove();
  }
}
function validation_submit(class_name_submit){
  if ($(class_name_submit).val() == ''){
    $(class_name_submit).parent().next().show();
    $(class_name_submit).parent().next().next().remove();
  }
}
function get_states (value) {
  $.ajax({
    type: "POST",
    dataType: "script",
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));},
    url: '/pcg/home/get_state_list',
    data: {country: value},
    success: function(){
      if($('#state').next('.holder').text() != 'Please select'){
        $("#state option").filter(function() {
          return $(this)[0].text == $('#state').next('.holder').text()
        }).attr('selected', true);
      }
    }
  });
}
