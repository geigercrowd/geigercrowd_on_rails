function onFocusClear(input) {
  input.value = '';
  input = $(input);
  input.unbind('focus');
  input.removeClass('onfocus_clear');
}

function showGoogleMaps() {
  var element = $('#google_map');
  var latitude = element.attr('data-latitude');
  var longitude = element.attr('data-longitude');
  element.width(780);
  element.height(400);
  var myLatlng = new google.maps.LatLng(latitude, longitude);
  var myOptions = {
    zoom: 12,
    center: myLatlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  var map = new google.maps.Map(document.getElementById('google_map'), myOptions);
  var marker = new google.maps.Marker({
      position: myLatlng, 
      map: map
  }); 
}

$(function() {
  $('#location_search').locationPicker();
  $('input.onfocus_clear').bind('focus', function() { onFocusClear(this) });
  $('#location_search').keypress(function (e) {
		if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
			return false;
		}
  });
  showGoogleMaps();
});

