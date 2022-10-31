
function onConnected(connection) {
    console.log('connection started');
    
}

function onConnectionError(error) {
    if (error && error.message) {
        console.error(error.message);
    }
}


function bindConnectionMessage(connection) {
    var messageCallback = function (message) {        
        console.log(message);
        updateView(message);
    };
    connection.on('broadcastMessage', messageCallback);
    connection.onclose(onConnectionError);
}


document.addEventListener('DOMContentLoaded', function () {



    const connection = new signalR.HubConnectionBuilder()
        .withUrl('/xeniel')
        .build();
    bindConnectionMessage(connection);
    connection.start()
        .then(() => onConnected(connection))
        .catch(error => console.error(error.message));



});

async function AJAXSubmit(oFormElement) {
    $('#thebody').html('<img src="/images/1480.gif"  style="height: 32px; width: 32px;" />');
    const formData = new FormData(oFormElement);

    try {
        const response = await fetch(oFormElement.action, {
            method: 'POST',
            body: formData
        });

        if (response.ok) {
            response.text().then(function (text) {
                console.log(text);
                $('#imageholder').html('<img src="' + JSON.parse(text).uri + '"  style="height: 500px; width: 400px;" />');
            });

        }
    } catch (error) {
        console.error('Error:', error);
    }
}


function updateView(data) {
    if (!data) return;
    var rows = [];
    console.log(data);

    if (data.description) {
        if (data.description.tags) {
            var values = [];
            data.description.tags.forEach(tag => {
                values.push('<span class="badge bg-danger text-light">' + tag + '</span>');
            });
            rows.push('<tr><td class="table-active">Tags</td><td>' + values.join('&nbsp;') + '</td></tr>')
        }
        if (data.description.captions) {
            var values = [];
            data.description.captions.forEach(caption => {
                values.push('<span>' + caption.text + ' </span> <span class="badge bg-info text-light">' + caption.confidence + ' Confidence </span>');
            });
            rows.push('<tr><td class="table-active">Caption</td><td>' + values.join('&nbsp;') + '</td></tr>')
        }
    }

    if (data.categories && data.categories.length > 0) {

        data.categories.forEach(category => {
            if (category.detail && category.detail.celebrities && category.detail.celebrities.length > 0) {
                var values = [];
                category.detail.celebrities.forEach(celeb => {
                    values.push('<span>' + celeb.name + ' </span> <span class="badge bg-info text-light">' + celeb.confidence + ' Confidence </span>');
                });
                rows.push('<tr><td class="table-active">Celebrity Indication</td><td>' + values.join('&nbsp;') + '</td></tr>')
            }
        });
    }

    $('#thebody').html(rows.join(''));
}