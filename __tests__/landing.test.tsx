import { cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";

import Home from "@/app/page";

afterEach(cleanup);

describe("landing page", () => {
  it("presents an honest product concept without exposing private audit details", () => {
    const { container } = render(<Home />);

    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("Your disk is not full of junk");
    expect(screen.getAllByRole("button", { name: "Windows app coming soon" }).length).toBe(2);
    expect(screen.getAllByRole("button", { name: "Windows app coming soon" }).every((button) => button.hasAttribute("disabled"))).toBe(true);
    expect(container.textContent).toContain("synthetic Windows audit data");
    expect(container.textContent).toContain("storageclean plan");
    expect(container.textContent).not.toContain("CCleaner");
    expect(container.textContent).not.toMatch(/673\.65|931\.50|158\.40|148\.12|125\.33|117\.96|9\.91|16\+ GiB/);
    expect(container.textContent).not.toMatch(/C:\\Users\\(?!you(?:\\|$))/i);
    expect(container.textContent).not.toMatch(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i);

    const prematureDownloads = container.querySelectorAll(
      'a[download], a[href$=".exe"], a[href$=".msi"], a[href$=".msix"], a[href*="installer"]',
    );
    expect(prematureDownloads.length).toBe(0);

    for (const link of container.querySelectorAll<HTMLAnchorElement>('a[href^="#"]')) {
      const id = link.getAttribute("href")?.slice(1);
      expect(id).toBeTruthy();
      expect(container.querySelectorAll(`#${id}`).length).toBe(1);
    }
  });
});
