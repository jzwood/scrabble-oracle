async function setupPixelManipulation() {
  // Get camera access
  const stream = await navigator.mediaDevices.getUserMedia({
    video: { facingMode: "environment" },
  });

  const video = document.createElement("video");
  video.srcObject = stream;
  await video.play();

  const canvas = document.getElementById("canvas");
  canvas.width = 525;
  canvas.height = 525;
  canvas.style.width = "500px";
  canvas.style.height = "500px";
  const context = canvas.getContext("2d");

  function processFrame() {
    // Draw current video frame to canvas
    context.drawImage(video, 0, 0, canvas.width, canvas.height);

    // Get pixel data
    const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
    const pixels = imageData.data;

    for (let i = 0; i < pixels.length; i += 4) {
      if ((i % 35 === 0) || (~~(i / 2_100) % 35 === 0)) {
        pixels[i] = pixels[i + 1] = pixels[i + 2] = 255;
      }
    }

    context.putImageData(imageData, 0, 0);
  }

  setInterval(processFrame, 100);
}

document.getElementById("start").addEventListener(
  "click",
  setupPixelManipulation,
);
