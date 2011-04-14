$(function() {
  $('#location_search').locationPicker();
  $('#location_search').keypress(function (e) {
		if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
			return false;
		}
  });
  $('input.onfocus_clear').focus(function() { this.value = '' });
});
