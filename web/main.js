function debug(text) {
  const node = document.createTextNode(text);
  const body = document.body;
  body.appendChild(node);
}

const GRID = 15
const PX_PER_SQUARE = 35
const SIDE = PX_PER_SQUARE * GRID
const SIDE_RGBA = 4 * SIDE

async function setupPixelManipulation() {
  // Get camera access
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: "environment" },
    });
    const video = document.createElement("video");
    video.srcObject = stream;
    await video.play();

    const canvas = document.getElementById("canvas");
    canvas.width = SIDE;
    canvas.height = SIDE;
    canvas.style.width = '100%';
    canvas.style.maxWidth = '90vh';
    canvas.style.margin = '0 auto';
    canvas.style.display = "block";
    const context = canvas.getContext("2d");

    function processFrame() {
      // Draw current video frame to canvas
      context.drawImage(video, 0, 0, canvas.width, canvas.height);

      // Get pixel data
      const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
      const pixels = imageData.data;

      for (let i = 0; i < pixels.length; i += 4) {
        if ((i % PX_PER_SQUARE === 0) || (~~(i / SIDE_RGBA) % PX_PER_SQUARE === 0)) {
          pixels[i] = pixels[i + 1] = pixels[i + 2] = 255;
        }
      }

      context.putImageData(imageData, 0, 0);
    }

    setInterval(processFrame, 100);
  } catch (err) {
    console.log("ERR", err);
    debug(String(err));
    return null;
  }
}

document.getElementById("start").addEventListener(
  "click",
  setupPixelManipulation,
);
