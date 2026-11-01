export const siteUrl = "https://storageclean.app";
export const siteUpdated = "2026-11-01";
export const siteUpdatedLabel = "November 1, 2026";
export const operator = {
  name: "Adam Pang",
  url: "https://adampang.com",
  email: "adamtpang@gmail.com",
};
export const repoUrl = "https://github.com/adamtpang/storageclean.app";
export const windowsDownloadUrl =
  "https://github.com/adamtpang/storageclean.app/releases/download/v0.3.0-beta.1/StorageClean-Setup-0.3.0-beta.1-win-x64.exe";

export const organizationJsonLd = {
  "@type": "Organization",
  "@id": `${siteUrl}/#organization`,
  name: "storageclean.app",
  url: siteUrl,
  logo: `${siteUrl}/icon.svg`,
  email: operator.email,
  founder: { "@type": "Person", name: operator.name, url: operator.url },
  sameAs: [repoUrl],
};
