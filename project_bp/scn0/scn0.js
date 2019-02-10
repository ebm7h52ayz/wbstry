var img = document.createElement('img');
img.src = 'data:image/jpeg;base64,' + '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';
document.body.appendChild(img);