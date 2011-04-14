function onFocusClear(input) {
  input.value = '';
  input = $(input);
  input.unbind('focus');
  input.removeClass('onfocus_clear');
}

$(function() {
  $('#location_search').locationPicker();
  $('input.onfocus_clear').bind('focus', function() { onFocusClear(this) });
  $('#location_search').keypress(function (e) {
		if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
			return false;
		}
  });
});
