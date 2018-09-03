function noenter() {
  var x = document.forms["search-form"]["search-box"].value;
  if (window.event.keyCode == 13){
    if (x == null || x == ""){
      return false;
    } else {
      return true;
    }
  }
}