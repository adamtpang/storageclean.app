import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { ThemeToggle } from "@/components/theme-toggle";
import { themeInitializer } from "@/lib/theme-script";

beforeEach(() => {
  window.localStorage.clear();
  document.documentElement.classList.remove("dark");
  document.documentElement.style.colorScheme = "";
  vi.mocked(window.matchMedia).mockImplementation((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  }));
});

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe("ThemeToggle", () => {
  it("applies and persists the selected theme", async () => {
    render(<ThemeToggle />);

    const toggle = await screen.findByRole("button", { name: "Switch to dark theme" });
    fireEvent.click(toggle);

    expect(document.documentElement.classList.contains("dark")).toBe(true);
    expect(document.documentElement.style.colorScheme).toBe("dark");
    expect(window.localStorage.getItem("storageclean-theme")).toBe("dark");
    expect(screen.getByRole("button", { name: "Switch to light theme" })).toBeTruthy();
  });

  it("restores a saved dark theme", async () => {
    window.localStorage.setItem("storageclean-theme", "dark");
    render(<ThemeToggle />);

    await waitFor(() => {
      expect(document.documentElement.classList.contains("dark")).toBe(true);
    });
    expect(screen.getByRole("button", { name: "Switch to light theme" })).toBeTruthy();
  });

  it("toggles a restored dark theme back to light", async () => {
    window.localStorage.setItem("storageclean-theme", "dark");
    render(<ThemeToggle />);

    const toggle = await screen.findByRole("button", { name: "Switch to light theme" });
    fireEvent.click(toggle);

    expect(document.documentElement.classList.contains("dark")).toBe(false);
    expect(document.documentElement.style.colorScheme).toBe("light");
    expect(window.localStorage.getItem("storageclean-theme")).toBe("light");
  });

  it("uses the system dark theme when no valid preference is saved", async () => {
    vi.mocked(window.matchMedia).mockImplementation((query: string) => ({
      matches: true,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));
    window.localStorage.setItem("storageclean-theme", "unsupported");
    render(<ThemeToggle />);

    await waitFor(() => {
      expect(document.documentElement.classList.contains("dark")).toBe(true);
    });
    expect(screen.getByRole("button", { name: "Switch to light theme" })).toBeTruthy();
  });

  it("honors a saved light theme over a dark system preference", async () => {
    vi.mocked(window.matchMedia).mockImplementation((query: string) => ({
      matches: true,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));
    window.localStorage.setItem("storageclean-theme", "light");
    render(<ThemeToggle />);

    await waitFor(() => {
      expect(document.documentElement.classList.contains("dark")).toBe(false);
    });
    expect(screen.getByRole("button", { name: "Switch to dark theme" })).toBeTruthy();
  });

  it("still toggles when browser storage is unavailable", async () => {
    vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => {
      throw new Error("storage unavailable");
    });
    vi.spyOn(Storage.prototype, "setItem").mockImplementation(() => {
      throw new Error("storage unavailable");
    });
    render(<ThemeToggle />);

    const toggle = await screen.findByRole("button", { name: "Switch to dark theme" });
    fireEvent.click(toggle);

    expect(document.documentElement.classList.contains("dark")).toBe(true);
    expect(document.documentElement.style.colorScheme).toBe("dark");
  });
});

describe("theme initializer", () => {
  it("uses the system theme before hydration when storage is unavailable", () => {
    vi.mocked(window.matchMedia).mockImplementation((query: string) => ({
      matches: true,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));
    vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => {
      throw new Error("storage unavailable");
    });

    Function(themeInitializer)();

    expect(document.documentElement.classList.contains("dark")).toBe(true);
    expect(document.documentElement.style.colorScheme).toBe("dark");
  });
});
