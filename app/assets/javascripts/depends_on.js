(function( $ ){
  
  $.fn.dependsOn = function(element, value, previousValue) {
    var elements = this;
    var hideOrShow = function() {
      var $this = $(this);
      var showEm;
      var showEm2;
      if ( $this.is('input[type="checkbox"]') ) {
        showEm = $this.is(':checked');
      } else if ($this.is('select')) {
        var fieldValue = $this.find('option:selected').val();
        if (typeof(value) == 'undefined') {
          showEm = fieldValue && $.trim(fieldValue) != '';
        } else if ($.isArray(value)) {
          showEm = $.inArray(fieldValue, value.map(function(v) {return v.toString()})) >= 0;
        } else {
          //fieldValue is selected value in dropdown
          //value is 'Other'
          showEm = value.toString() == fieldValue;
          
        }
      }
      $(elements).val(fieldValue);
      elements.toggle(showEm);
    }
    var fieldValue = $(element).find('option:selected').val();
    if(fieldValue!=previousValue) {
      $(element).val('Other');
    }
    //add change handler to element
    //element is category_picker or type_picker
    $(element).change(hideOrShow);
 
    //hide the dependent fields
    $(element).each(hideOrShow);

    if(fieldValue!=previousValue) {
      $(this).val(previousValue);
    }
    return elements;
  };
  
  $(document).on('ready page:load', function() {
    $('*[data-depends-on]').each(function() {
      var $this = $(this);
      var master = $this.data('dependsOn').toString();
      var value = $this.data('dependsOnValue');
      var previousValue = $this.val();
      //alert(previousValue);
      if (typeof(value) != 'undefined') {
        $this.dependsOn(master, value, previousValue);
      } else {
        $this.dependsOn(master);
      }
    });
  });
});