export const themeInitializer = `
(() => {
  let stored = null;
  try {
    stored = window.localStorage.getItem("storageclean-theme");
  } catch {}

  const validStored = stored === "light" || stored === "dark" ? stored : null;
  let prefersDark = false;
  try {
    prefersDark = window.matchMedia?.("(prefers-color-scheme: dark)").matches ?? false;
  } catch {}

  const theme = validStored ?? (prefersDark ? "dark" : "light");
  document.documentElement.classList.toggle("dark", theme === "dark");
  document.documentElement.style.colorScheme = theme;
})();`;
