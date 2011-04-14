/*
 * 
 */

(function($){

    //Attach this new method to jQuery
    $.fn.extend({ 
        
        //This is where you write your plugin's name
        locationPicker: function() {
            
            var options = {
                width: "450px",
                height: "450px",
                backgroundColor: '#fff',
                border: '1px solid #ccc',
                borderRadius: 10,
                padding: 10,
                defaultLat: 51.500152,
                defaultLng: -0.126236            
            };
            
            function RoundDecimal(num, decimals){
                var mag = Math.pow(10, decimals);
                return Math.round(num * mag)/mag;
            };
            
            var geocoder = new google.maps.Geocoder();
            
            //var mapsScript = document.createElement( 'script' );
            //mapsScript.type = 'text/javascript';
            //mapsScript.src = "http://maps.google.com/maps/api/js?sensor=false&callback=lptoremove";
            //$(this).before( mapsScript );

            //Iterate over the current set of matched elements
            return this.each(function() {
                
                var that = this;
                
                var setPosition = function(latLng, viewport){
                    var lat = RoundDecimal(latLng.lat(), 6);
                    var lng = RoundDecimal(latLng.lng(), 6);
                    marker.setPosition(latLng);
                    if(viewport){
                        //map.fitBounds(viewport);
                        //map.setZoom(map.getZoom() + 2);
                    }else{
                        map.panTo(latLng);
                    }
                   // $(that).val(lat + "," + lng);
                  document.getElementById('location_latitude').value=lat;
                  document.getElementById('location_longitude').value=lng;

                }
                
                var id = $(this).attr('id');
                
                var searchButton = $("<input class='picker-search-button' type='button' value='...find'/>");
                $(this).after(searchButton);
               
                var picker = $("<div id='" + id + "-picker' class='pickermap'></div>").css({
                    width: options.width,
                    backgroundColor: options.backgroundColor,
                    border: options.border,
                    padding: options.padding,
                    borderRadius: options.borderRadius,
                    position: "absolute",
                    display: "none"
                });
                $(this).after(picker);
                var mapDiv = $("<div class='picker-map'>Loading</div>").css({
                    height: options.height
                });
                picker.append(mapDiv);
                
                var myLatlng = new google.maps.LatLng(options.defaultLat, options.defaultLng);
                var myOptions = {
                    zoom: 13,
                    center: myLatlng,
                    mapTypeId: google.maps.MapTypeId.ROADMAP,
                    mapTypeControl: false,
                    disableDoubleClickZoom: true,
                    streetViewControl: false
                }
                var map = new google.maps.Map(mapDiv.get(0), myOptions);
                
                var marker = new google.maps.Marker({
                    position: myLatlng, 
                    map: map, 
                    title: "Drag Me",
                    draggable: true
                });
                
                google.maps.event.addListener(map, 'dblclick', function(event) {
                    setPosition(event.latLng);
                });
                google.maps.event.addListener(map, 'click', function(event) {
                    setPosition(event.latLng);
                });
                google.maps.event.addListener(marker, 'dragend', function(event) {
                    setPosition(marker.position);
                });
                google.maps.event.addListener(map, 'zoom_changed', function() {
                  map.panTo(marker.position);
                });

                function getCurrentPosition(){
                    var posStr = $(that).val();
                    if(posStr != ""){
                        var posArr = posStr.split(",");
                        if(posArr.length == 2){
                            var lat = $.trim(posArr[0]);
                            var lng = $.trim(posArr[1]);
                            var latlng = new google.maps.LatLng(lat, lng);
                            setPosition(latlng);
                            return;
                        }
                        //$(that).val("Invalid Position");
                    }
                    
                }
                
                function showPicker(){
                    picker.fadeIn('fast');
                    google.maps.event.trigger(map, 'resize');
                    getCurrentPosition();
                    map.setCenter(marker.position);
                }
                
                $(this).focus(function(){
                    var address = $(that).val();
                    if(isLngLat(address)){
                        showPicker();
                    }
                });
                
                $(":input").focus(function(){
                    if($(this).attr('id') != $(that).attr('id')){
                        if($(picker).children(this).length == 0){
                            picker.fadeOut('fast');
                        }
                    }
                });
                
                function isLngLat(val){
                    var lngLatArr = val.split(",");
                    if(lngLatArr.length == 2){
                        if(isNaN(lngLatArr[0]) || isNaN(lngLatArr[1])){
                            return false;
                        }else{
                            return true;
                        }
                    }
                    return false;
                }
                
                function findAddress(){
                    var address = $(that).val();
                    if(address == ""){
                        alert("Please enter an address or Lng/Lat position.");
                    }else{
                        if(isLngLat(address)){
                            showPicker();
                        }else{
                            geocoder.geocode( {'address': address, 'region': 'uk'}, function(results, status) {
                                if (status == google.maps.GeocoderStatus.OK) {
                                    setPosition(
                                        results[0].geometry.location,
                                        results[0].geometry.viewport
                                    );
                                    showPicker();
                                } else {
                                    alert("Geocode was not successful for the following reason: " + status);
                                }
                            });
                        }
                        //$(that).focus();
                    }
                }
                
                
                
                $(searchButton).click(function(event){
                    findAddress();
                    event.stopPropagation();
                });
                
                $(that).keydown(function(event) {
                    if (event.keyCode == '13') { // enter
                        findAddress();
                        event.stopPropagation();
                    } else if (event.keyCode == '9') {
                       picker.fadeOut('fast');
                    }
                });
                
                $('html').click(function() {
                    picker.fadeOut('fast');
                });
                
                $(picker).click(function(event){
                    event.stopPropagation();
                    //$(that).focus();
                });
                
                $(this).click(function(event){
                    event.stopPropagation();
                });


            
            });
            
            
        }
        
    });
       
})(jQuery);