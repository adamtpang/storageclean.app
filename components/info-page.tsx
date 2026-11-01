import { BrandMark, SiteFooter } from "@/components/site-footer";
import { ThemeToggle } from "@/components/theme-toggle";

export function InfoPage({ eyebrow, title, children }: { eyebrow: string; title: string; children: React.ReactNode }) {
  return (
    <main className="page-shell min-h-screen overflow-x-clip">
      <header className="border-b border-border/80 bg-background/80">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 md:px-6 lg:px-8">
          <a href="/" className="focus-ring inline-flex min-h-11 items-center gap-3 rounded-md pr-2" aria-label="storageclean.app home">
            <BrandMark />
            <span className="text-sm font-semibold tracking-tight">storageclean.app</span>
          </a>
          <ThemeToggle />
        </div>
      </header>
      <section className="mx-auto max-w-3xl px-4 py-16 md:px-6 md:py-24">
        <div className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">{eyebrow}</div>
        <h1 className="mt-4 text-balance text-4xl font-semibold tracking-[-0.04em] sm:text-5xl">{title}</h1>
        <div className="mt-8 space-y-5 text-base leading-7 text-muted-foreground [&_a]:text-foreground [&_a]:underline [&_a]:underline-offset-4 [&_h2]:pt-4 [&_h2]:text-xl [&_h2]:font-semibold [&_h2]:text-foreground [&_li]:ml-5 [&_li]:list-disc">
          {children}
        </div>
      </section>
      <SiteFooter />
    </main>
  );
}
