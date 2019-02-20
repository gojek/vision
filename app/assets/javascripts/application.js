// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//= require jquery2
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-ui
//= require admin-lte/plugins/select2/select2.full
//= require moment/min/moment.min
//= require tinymce
//= require eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min
//= require ./daterangepicker
//= require cocoon
//= require admin-lte
//= require nprogress
//= require nprogress-turbolinks
//= require fullcalendar
//= require amcharts3/amcharts/amcharts
//= require amcharts3/amcharts/pie
//= require amcharts3/amcharts/serial
//= require amcharts3/amcharts/themes/light
//= require Chart.js/Chart.min
//= require data-confirm-modal
//= require Caret.js/dist/jquery.caret.js
//= require At.js/dist/js/jquery.atwho.min
//= require turbolinks
//= require noenter
//= require bootstrap-toggle

NProgress.configure({


});
$(function(){
  $(".select2").select2();
  $('.datetimepicker').datetimepicker({
    format: "yyyy-mm-dd"
  });

  $('.hide-unhide-comment').on('ajax:success', function(data, response){
    var comment_id = response.id;
    var cr_id = response.change_request_id;
    var new_link = '/change_requests/'+ cr_id +'/comments/'+ comment_id +'/hide?type=';
    if(response.hide){
      $('#p-comment-'+comment_id).addClass('hidden');
      $('#p-show-comment-'+comment_id).removeClass('hidden');
      $('#hide-unhide-comment-'+comment_id).attr('href', new_link + 'unhide');
      $('#hide-unhide-comment-'+comment_id).html('Unhide');
    }
    else{
      $('#p-comment-'+comment_id).removeClass('hidden');
      $('#p-show-comment-'+comment_id).addClass('hidden');
      $('#hide-unhide-comment-'+comment_id).attr('href', new_link + 'hide');
      $('#hide-unhide-comment-'+comment_id).html('Hide');
    }
  });

  $('.hide-unhide-access-request-comment').on('ajax:success', function(data, response){
    var comment_id = response.id;
    var ar_id = response.access_request_id;
    var new_link = '/access_requests/'+ ar_id +'/access_request_comments/'+ comment_id +'/hide?type=';
    if(response.hide){
      $('#p-access-request-comment-'+comment_id).addClass('hidden');
      $('#p-show-access-request-comment-'+comment_id).removeClass('hidden');
      $('#hide-unhide-access-request-comment-'+comment_id).attr('href', new_link + 'unhide');
      $('#hide-unhide-access-request-comment-'+comment_id).html('Unhide');
    }
    else{
      $('#p-access-request-comment-'+comment_id).removeClass('hidden');
      $('#p-show-access-request-comment-'+comment_id).addClass('hidden');
      $('#hide-unhide-access-request-comment-'+comment_id).attr('href', new_link + 'hide');
      $('#hide-unhide-access-request-comment-'+comment_id).html('Hide');
    }
  });

});
$(document).on('page:fetch',   function() { NProgress.set(0.3); });

function show_comment(comment){
	var commentId = comment.getAttribute('data-comment-id');
	$(comment).addClass('hidden');
	$('#p-comment-'+commentId).removeClass('hidden');
}

function tableAutoHeight(selector, min_height){
  var dh = $(document).height();
  var vh = $(window).height();
  var th = $(selector).height();
  var tp = $(selector).offset();

  var toph = tp.top;
  var bottomh = dh - toph - th;
  var tr = vh - toph - bottomh;

  if(tr < min_height) return;

  $(selector).height(tr);
}
