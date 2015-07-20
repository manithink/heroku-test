$(document).ready(function(){

        // alert('Yes')

       function selectbox() {
        $(".custom-select, .custom-select-box").each(function(){
            $(this).wrap("<span class='select-wrapper'></span>");
            $(this).after("<span class='holder'></span>");
        });
        $(".custom-select,.custom-select-box").change(function(){
            var selectedOption = $(this).find(":selected").text();
            $(this).next(".holder").text(selectedOption);
        }).trigger('change');
        //checkbox
        $('.label_check, .label_radio').click(function(){
            setupLabel();
        });
        setupLabel();

        function setupLabel() {
            if ($('.label_check input').length) {
                $('.label_check').each(function(){
                    $(this).removeClass('c_on');
                });
                $('.label_check input:checked').each(function(){
                    $(this).parent('label').addClass('c_on');
                });
            };
            
            if ($('.label_radio input').length) {
                $('.label_radio').each(function(){
                    $(this).removeClass('r_on');
                });
                $('.label_radio input:checked').each(function(){
                    $(this).parent('label').addClass('r_on');
                });
            };
        };
    }
    selectbox();
})
// $(document).on('page:load', selectbox)


