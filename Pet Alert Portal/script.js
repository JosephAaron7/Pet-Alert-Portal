document.addEventListener('DOMContentLoaded', function () {
    // Initialize Google Maps
    initMap();

    // Attach event listeners
    document.querySelector('#detectLocation').addEventListener('click', detectLocation);
    document.querySelector('#exportData').addEventListener('click', exportDataAsCSV);
    document.querySelector('#shareFacebook').addEventListener('click', shareOnFacebook);
    document.querySelector('#shareWhatsApp').addEventListener('click', shareOnWhatsApp);
    document.querySelector('#donateButton').addEventListener('click', donateNow);
});

// Initialize Google Maps
function initMap() {
    let map = new google.maps.Map(document.getElementById("map"), {
        center: { lat: -34.397, lng: 150.644 },
        zoom: 8,
    });

    map.addListener("click", (e) => {
        placeMarker(map, e.latLng);
        document.querySelector('#location').value = `Latitude: ${e.latLng.lat()}, Longitude: ${e.latLng.lng()}`;
    });
}

function detectLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(position => {
            document.querySelector('#location').value = `Latitude: ${position.coords.latitude}, Longitude: ${position.coords.longitude}`;
        }, error => {
            alert('Error getting location: ' + error.message);
        });
    } else {
        alert('Geolocation not supported by your browser.');
    }
}

function exportDataAsCSV() {
    let csvContent = "data:text/csv;charset=utf-8,Report Type,Animal Type,Location,Description\n";
    const reports = document.querySelectorAll('#reportsList .list-group-item');
    reports.forEach(report => {
        csvContent += report.textContent.split(' - ').join(',') + "\n";
    });

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "animal_reports.csv");
    link.click();
}

function shareOnFacebook() {
    const url = 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(window.location.href);
    window.open(url, '_blank');
}

function shareOnWhatsApp() {
    const message = "Help find this missing or injured animal: " + window.location.href;
    const url = 'https://api.whatsapp.com/send?text=' + encodeURIComponent(message);
    window.open(url, '_blank');
}

function donateNow() {
    window.open('https://www.facebook.com/profile.php?id=61567462995078&mibextid=LQQJ4d', '_blank');
}

function placeMarker(map, position) {
    if (window.marker) {
        window.marker.setMap(null);
    }
    window.marker = new google.maps.Marker({
        position: position,
        map: map,
    });
}