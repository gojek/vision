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
//= require Sortable
//= require depends_on
//= require admin-lte/plugins/select2/select2.full
//= require moment/min/moment.min
//= require tinymce
//= require eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min
//= require cocoon
//= require admin-lte
//= require moment
//= require nprogress
//= require nprogress-turbolinks
//= require fullcalendar
//= require amcharts
//= require pie
//= require serial
//= require light
//= require Chart.js/Chart.min
//= require data-confirm-modal

//= require daterangepicker
//= require turbolinks
//= require bootstrap-toggle
NProgress.configure({


});
$(function(){
  $(".select2").select2();
  //$(".select2-tag").val(["cr@***REMOVED***", "stig@***REMOVED***"]);
  //$(".select2-tag").select2({
  	//tags: true,
  	//tokenSeparators: [',', ' ']
  //});
  $('.datetimepicker').datetimepicker({
    format: "yyyy-mm-dd"
  });
});
$(document).on('page:fetch',   function() { NProgress.set(0.3); });
