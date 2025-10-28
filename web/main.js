function debug(text) {
  const node = document.createTextNode(text);
  const body = document.body;
  body.appendChild(node);
}

const GRID = 15;
const PX_PER_SQUARE = 35;
const SIDE = PX_PER_SQUARE * GRID;
const SIDE_RGBA = 4 * SIDE;

function getVideo() {
  return navigator.mediaDevices.getUserMedia({
    video: { facingMode: "environment" },
  })
    .then((stream) => {
      const video = document.createElement("video");
      video.srcObject = stream;
      return video.play().then(() => video);
    })
    .then((video) => {
      const canvas = document.getElementById("canvas");
      canvas.width = SIDE;
      canvas.height = SIDE;
      const context = canvas.getContext("2d");
      return { video, context };
    });
}

function processFrame({ video, context }) {
  context.drawImage(video, 0, 0, SIDE, SIDE);
  const imageData = context.getImageData(0, 0, SIDE, SIDE);
  const pixels = imageData.data;
  for (let i = 0; i < pixels.length; i += 4) {
    if (
      (i % PX_PER_SQUARE === 0) ||
      (Math.floor(i / SIDE_RGBA) % PX_PER_SQUARE === 0)
    ) {
      pixels[i] = pixels[i + 1] = pixels[i + 2] = 255;
    }
  }
  context.putImageData(imageData, 0, 0);
}

function ready(fn) {
  if (document.readyState !== "loading") {
    fn();
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
}

function main() {
  let id = null;
  let loading = false;
  document.getElementById("start")
    .addEventListener("click", () => {
      if (loading) return null;
      loading = true;
      getVideo()
        .then(({ video, context }) => {
          clearInterval(id);
          id = setInterval(() => processFrame({ video, context }), 100);
        })
        .catch((err) => {
          console.error(err);
        })
        .finally(() => {
          loading = false;
        });
    });
}

ready(main);
