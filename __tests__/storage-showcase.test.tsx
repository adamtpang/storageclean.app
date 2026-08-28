import { cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";

import { StorageShowcase } from "@/components/storage-showcase";

afterEach(cleanup);

describe("StorageShowcase", () => {
  it("switches between synthetic audits and their matching recommendations", () => {
    render(<StorageShowcase />);

    const laptop = screen.getByRole("button", { name: "Laptop" });
    const ssd = screen.getByRole("button", { name: "SSD" });
    const selector = screen.getByRole("group", { name: "Choose storage device" });
    const liveRegion = document.querySelector('[aria-live="polite"]');

    expect(within(selector).getAllByRole("button").length).toBe(2);
    expect(laptop.getAttribute("aria-pressed")).toBe("true");
    expect(screen.getByText("680 GiB example")).toBeTruthy();
    expect(screen.getByText("Development")).toBeTruthy();
    expect(screen.getByText("Stop recurring temporary growth first.")).toBeTruthy();
    expect(liveRegion?.textContent).toContain("680 GiB example");

    fireEvent.click(ssd);

    expect(ssd.getAttribute("aria-pressed")).toBe("true");
    expect(laptop.getAttribute("aria-pressed")).toBe("false");
    expect(screen.getByText("930 GiB example")).toBeTruthy();
    expect(screen.getByText("External SSD")).toBeTruthy();
    expect(screen.getByText("Verify the archive, then move cold media.")).toBeTruthy();
    expect(screen.queryByText("Stop recurring temporary growth first.")).toBeNull();
    expect(liveRegion?.textContent).toContain("930 GiB example");
  });
});
