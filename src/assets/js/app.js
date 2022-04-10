protos = [$client,$bert]; N2O_start();

function closeHelp(e) {
    e.preventDefault();
    qi('help-callout').style.display = 'none';
};

function clearAltForm() {
    qi('alt_text').value = '';
};

function onSliderChange(slider) {
    console.log(slider.value);
    var text = qi(slider.id + 'text');
    text.classList.remove('bg-success');
    text.classList.remove('bg-danger');

    if (slider.value > 0) {
        text.classList.add('bg-success');
        text.innerHTML = "+" + slider.value;
    }
    
    if (slider.value < 0) {
        text.classList.add('bg-danger');
        text.innerHTML = "&minus;" + (-slider.value);
    }
    
    if (slider.value == 0) {
        text.innerHTML = "&empty;";
    }
}

function voteSubmit(event) {
    event.preventDefault();

    if (!validateName()) {
        return false;
    }

    var x = document.querySelectorAll("#alts input[id^=\"vote\"]");
    var votes = [];
    for (var i = 0; i < x.length; i++) {
        votes.push([x[i].id.substring(4), x[i].value]);
    };

    data = {
        title:  qi('title') ? qi('title').value : '',
        name: qi('name').value,
        votes: votes,
        // add alternative
        alt_text: qi('alt_text').value
    };
    vote(data);
    
    return false;
};

function validateName() {
    var text = qi('name').value.trim();
    if (text === '') {
        qi('name').classList.add('is-invalid');
        return false;
    }

    qi('name').classList.remove('is-invalid"');
    return true;
};

// This is called with the results from from FB.getLoginStatus().
function statusChangeCallback(response) {
    console.log('statusChangeCallback');
    if (response.status === 'connected') {
        // Logged into your app and Facebook.
        fb_login(response.authResponse.accessToken);
    } else if (response.status === 'not_authorized') {
        alert('Please log into this app.');
    } else {
        alert('Please log into Facebook.');
    }
}

function checkLoginState() {
    FB.getLoginStatus(function(response) {
      statusChangeCallback(response);
    });
}
