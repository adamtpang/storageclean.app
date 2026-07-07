const scanButton = document.querySelector("#scanButton");
const rows = document.querySelectorAll(".row");

scanButton?.addEventListener("click", () => {
  scanButton.textContent = "Scanning";
  rows.forEach((row, index) => {
    row.animate(
      [
        { transform: "translateY(8px)", opacity: 0.45 },
        { transform: "translateY(0)", opacity: 1 }
      ],
      {
        delay: index * 90,
        duration: 360,
        easing: "cubic-bezier(.2,.8,.2,1)"
      }
    );
  });

  window.setTimeout(() => {
    scanButton.textContent = "Scan";
  }, 650);
});
