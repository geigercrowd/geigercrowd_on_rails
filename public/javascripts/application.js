function onFocusClear(input) {
  input.value = '';
  input = $(input);
  input.unbind('focus');
  input.removeClass('onfocus_clear');
}

$(function() {
  $('#location_search').locationPicker();
  $('input.onfocus_clear').bind('focus', function() { onFocusClear(this) });
});
