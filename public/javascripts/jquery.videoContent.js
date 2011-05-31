(function($) {
  $(document).ready(function() {
    $('input:radio[name=file_radio]').change(function(){
      if ($('input:radio[name=file_radio]:checked').val() == 'upload_file'){
        $('#link_to_file').hide();
        $('#uploader-contents').show();
      } else {
        $('#link_to_file').show();
        $('#uploader-contents').hide();
      }
    }),
    $('select[rel*="country"]').change(function(){
       var url = $("input#location_state").first().attr("value");
       var params = "cntry_name="+$('select[rel*="country"]').val();
       var showDiv=$("div.state");
       var perviousNode=$("div.state").first();
      $.ajax({
         type: "POST",
         url: url,
         dataType: "html",
         data: params,
         success: function(data){
           $(showDiv).html(data);
             $('div.state input.editable-edit').hydraTextField();
         },
         error: function(xhr, textStatus, errorThrown){
     		$.noticeAdd({
             inEffect:               {opacity: 'show'},      // in effect
             inEffectDuration:       600,                    // in effect duration in milliseconds
             stayTime:               6000,                   // time in milliseconds before the item has to disappear
             text:                   'Your changes failed'+ xhr.statusText + ': '+ xhr.responseText,
             stay:                   true,                  // should the notice item stay or not?
             type:                   'error'                // could also be error, success
            });
         }
       });
    });
  });
})(jQuery)
