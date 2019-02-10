function getImageBLOB(imageName) {
  for (const image of imageContainer) {
    if (imageName === image.name) {
        return image.code
    }
  }
  return undefined
}

function draw() { // accept a js object of images and locations? { images: { name: 'name', x: 'x', y: 'y'} } ?
  // auto resize canvas ?
  var c = document.getElementById("primeCanvas");
  var ctx = c.getContext("2d");
  ctx.canvas.width  = window.innerWidth;
  ctx.canvas.height = window.innerHeight;
  var img = document.createElement('img');
  img.src = 'data:image/jpeg;base64,' + getImageBLOB("./project_bp/scn0/test.png");
  ctx.drawImage(img, 10, 10);
};
