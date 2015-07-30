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
//= require Sortable
//= require depends_on
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-ui
//= require autocomplete-rails
//= require admin-lte/plugins/select2/select2.full
//= require moment/min/moment.min
//= require admin-lte/plugins/bootstrap-wysihtml5/bootstrap3-wysihtml5.all.min
//= require eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min
//= require cocoon
//= require admin-lte
//= require bootstrap-sprockets
//= require turbolinks
$(function(){
  $(".select2").select2();
  $('.textarea').wysihtml5();
  $('.datetimepicker').datetimepicker({
    format: "yyyy-mm-dd"
  });
});