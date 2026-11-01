import { Layers3 } from "lucide-react";

import { operator, siteUpdated, siteUpdatedLabel } from "@/lib/site";

const footerLinks = [
  { href: "/about", label: "About" },
  { href: "/contact", label: "Contact" },
  { href: "/privacy", label: "Privacy" },
];

export function BrandMark() {
  return (
    <span className="grid size-9 grid-cols-3 items-end gap-0.5 rounded-lg bg-primary p-2 text-primary-foreground" aria-hidden="true">
      <span className="h-2 rounded-sm bg-current opacity-60" />
      <span className="h-3.5 rounded-sm bg-current opacity-80" />
      <span className="h-5 rounded-sm bg-current" />
    </span>
  );
}

export function SiteFooter() {
  return (
    <footer className="border-t border-border bg-background/70">
      <div className="mx-auto flex max-w-7xl flex-col gap-5 px-4 py-8 text-xs text-muted-foreground lg:flex-row lg:items-center lg:justify-between md:px-6 lg:px-8">
        <div className="flex items-center gap-3">
          <BrandMark />
          <div>
            <div className="font-semibold text-foreground">storageclean.app</div>
            <div className="mt-1">Audit first. Confirm exact targets. Verify every result.</div>
            <div className="mt-1">
              Built by{" "}
              <a className="focus-ring underline underline-offset-4 hover:text-foreground" href={operator.url} rel="author">
                {operator.name}
              </a>
              . Updated <time dateTime={siteUpdated}>{siteUpdatedLabel}</time>.
            </div>
          </div>
        </div>
        <nav aria-label="Site information" className="flex flex-wrap items-center gap-5 text-sm">
          {footerLinks.map((link) => (
            <a key={link.href} className="focus-ring inline-flex min-h-11 items-center rounded-md hover:text-foreground" href={link.href}>
              {link.label}
            </a>
          ))}
        </nav>
        <div className="flex items-center gap-2 font-mono tabular-nums">
          <Layers3 aria-hidden="true" className="size-4" strokeWidth={1.8} />
          <span>Windows read-only beta · v0.3.0</span>
        </div>
      </div>
    </footer>
  );
}
