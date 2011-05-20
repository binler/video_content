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
    });
  });
})(jQuery)
