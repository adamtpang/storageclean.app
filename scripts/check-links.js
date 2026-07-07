const fs = require("node:fs");

const html = fs.readFileSync("index.html", "utf8");
const required = [
  "Storage Clean",
  "Find space. Remove what is safe.",
  "https://github.com/adamtpang/storageclean.app",
  "application/ld+json"
];

for (const text of required) {
  if (!html.includes(text)) {
    console.error(`Missing required text: ${text}`);
    process.exitCode = 1;
  }
}

if (!process.exitCode) {
  console.log("Landing page checks passed.");
}
