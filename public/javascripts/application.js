$(function() {
  $('#location_search').locationPicker();
  $('input.onfocus_clear').focus(function() { this.value = '' });
});
