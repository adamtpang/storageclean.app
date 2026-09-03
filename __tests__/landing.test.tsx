import { cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";

import Home from "@/app/page";

afterEach(cleanup);

describe("landing page", () => {
  it("presents an honest read-only beta without exposing private audit details", () => {
    const { container } = render(<Home />);
    const expectedDownload =
      "https://github.com/adamtpang/storageclean.app/releases/download/v0.3.0-beta.1/StorageClean-Setup-0.3.0-beta.1-win-x64.exe";

    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("Your disk is not full of junk");
    const downloadLinks = screen.getAllByRole("link", { name: "Download Windows beta" });
    expect(downloadLinks.length).toBe(2);
    expect(downloadLinks.every((link) => link.getAttribute("href") === expectedDownload)).toBe(true);
    expect(container.textContent).toContain("Read-only Windows beta available");
    expect(container.textContent).toContain("storageclean plan");
    expect(container.textContent).not.toContain("CCleaner");
    expect(container.textContent).not.toMatch(/673\.65|931\.50|158\.40|148\.12|125\.33|117\.96|9\.91|16\+ GiB/);
    expect(container.textContent).not.toMatch(/C:\\Users\\(?!you(?:\\|$))/i);
    expect(container.textContent).not.toMatch(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i);

    const executableDownloads = container.querySelectorAll(
      'a[download], a[href$=".exe"], a[href$=".msi"], a[href$=".msix"], a[href*="installer"]',
    );
    expect(executableDownloads.length).toBe(2);
    expect(Array.from(executableDownloads).every((link) => link.getAttribute("href") === expectedDownload)).toBe(true);

    for (const link of container.querySelectorAll<HTMLAnchorElement>('a[href^="#"]')) {
      const id = link.getAttribute("href")?.slice(1);
      expect(id).toBeTruthy();
      expect(container.querySelectorAll(`#${id}`).length).toBe(1);
    }
  });

  it("keeps the sticky header out of any scroll-container ancestor", () => {
    const { container } = render(<Home />);
    const header = container.querySelector("header");

    expect(header?.className).toContain("sticky");
    expect(header?.className).toContain("top-0");

    // overflow-hidden, overflow-auto, and overflow-scroll create a scroll container
    // that carries a nested sticky header away; overflow-*-clip is the only safe clip.
    for (let node = header?.parentElement; node; node = node.parentElement) {
      expect(node.className).not.toMatch(/overflow(?:-[xy])?-(?:hidden|auto|scroll)/);
    }
  });
});
