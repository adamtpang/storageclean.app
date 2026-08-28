export const laptopAudit = {
  label: "Laptop system drive",
  headline: "680 GiB example",
  subline: "The top four folders hold about 81% of this synthetic dataset",
  topShare: "About 81%",
  items: [
    { label: "Application data", value: 160, display: "160 GiB", share: "23.5%", cumulative: "23.5%" },
    { label: "Desktop", value: 150, display: "150 GiB", share: "22.1%", cumulative: "45.6%" },
    { label: "Pictures", value: 125, display: "125 GiB", share: "18.4%", cumulative: "64.0%" },
    { label: "Development", value: 115, display: "115 GiB", share: "16.9%", cumulative: "80.9%" },
    { label: "Everything else", value: 130, display: "130 GiB", share: "19.1%", cumulative: "100%" },
  ],
  action: {
    title: "Stop recurring temporary growth first.",
    copy: "The example flags a temporary profile that regrows after cleanup. Remove only confirmed cache targets, then fix the process that recreates them.",
    metricLabel: "Estimated opportunity",
    metric: "10-20 GiB",
    detail: "Illustrative range. Personal media and application data stay excluded until reviewed.",
  },
} as const;

export const ssdAudit = {
  label: "External SSD",
  headline: "930 GiB example",
  subline: "Archive and video hold about 98% of used space in this synthetic dataset",
  items: [
    { label: "Archive", value: 410, display: "410 GiB", cumulative: "75.9% used" },
    { label: "Video", value: 120, display: "120 GiB", cumulative: "98.1% used" },
    { label: "Temporary", value: 5, display: "5 GiB", cumulative: "99.1% used" },
    { label: "Other", value: 5, display: "5 GiB", cumulative: "100% used" },
    { label: "Free", value: 390, display: "390 GiB", cumulative: "41.9% capacity" },
  ],
  action: {
    title: "Verify the archive, then move cold media.",
    copy: "The example treats large archives as move candidates, not junk. Confirm another readable copy before reclaiming laptop space or changing the SSD.",
    metricLabel: "Potential move candidate",
    metric: "100+ GiB",
    detail: "Illustrative range. Verify the destination and source before proposing any deletion.",
  },
} as const;
