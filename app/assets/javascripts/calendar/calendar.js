 $.ajaxSetup({
 	statusCode: {
 		401: function(e) {
 			$.ajax({
 				type: "POST",
 				url: "/get_company_session_url",
 				success: function(data_url){
 					location.href = data_url;
 				}
 			});
 		}
 	}
 });