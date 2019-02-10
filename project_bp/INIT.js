function getImageBLOB(imageName) {
  for (const image of imageContainer) {
    if (imageName === image.name) {
        return image.code
    }
  }
  return undefined
}

// TODO: get click location and compare against click zone list with effects

function logMousePos(event) {
  console.log("clientX: " + event.clientX + " - clientY: " + event.clientY);
}

// TODO: load multiple images
function draw() { // accept a js object of images and locations to draw? { images: { name: 'name', x: 'x', y: 'y'} } ?
  // auto resize canvas ?
  var c = document.getElementById("primeCanvas");
  var ctx = c.getContext("2d");
  // keep canvas sized to window
  ctx.canvas.width  = window.innerWidth -10;
  ctx.canvas.height = window.innerHeight -10;
  var img = document.createElement('img');
  img.src = 'data:image/jpeg;base64,' + getImageBLOB("./project_bp/scn0/test.png");
  ctx.drawImage(img, 10, 10);
};

window.onload = function() { // hook event listeners
  document.addEventListener("click", logMousePos);

  // TODO: main game loop
  draw();
}
