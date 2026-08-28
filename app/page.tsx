import {
  ArchiveRestore,
  ArrowRight,
  Binary,
  Check,
  CircleGauge,
  Code2,
  CopyCheck,
  FileHeart,
  Fingerprint,
  Gauge,
  HardDriveDownload,
  Layers3,
  LockKeyhole,
  MonitorDown,
  ScanSearch,
  ShieldCheck,
  Sparkles,
} from "lucide-react";

import { StorageShowcase } from "@/components/storage-showcase";
import { ThemeToggle } from "@/components/theme-toggle";
import { laptopAudit } from "@/lib/audit-data";

const proofPoints = [
  { value: "Power law", label: "rank what matters", detail: "focus attention on the few folders driving most usage" },
  { value: "Only copy", label: "protect what is irreplaceable", detail: "separate disposable files from personal originals" },
  { value: "Proof", label: "verify every action", detail: "compare the expected result with the filesystem afterward" },
];

const laptopTopMax = Math.max(...laptopAudit.items.slice(0, 4).map((folder) => folder.value));

const wedges = [
  {
    icon: FileHeart,
    label: "Irreplaceability",
    title: "Find the only copy before touching it.",
    copy: "A media folder is not a file type. It can contain downloaded films, camera originals, project footage, and exports with no backup. The planned app separates them before recommending an action.",
    note: "Protect first",
  },
  {
    icon: ArchiveRestore,
    label: "More than delete",
    title: "Choose the right action for each file.",
    copy: "Delete caches. Compress oversized originals. Move cold archives. Uninstall dormant applications. Skip efficient files when the expected recovery is not worth the time.",
    note: "Delete · Move · Compress · Uninstall",
  },
  {
    icon: Code2,
    label: "Developer aware",
    title: "Trace structural growth, not just extensions.",
    copy: "Planned detection covers duplicate clones, stale worktrees, repeated node_modules, runaway test profiles, symlink recursion, and generated corpora that quietly enter backups or git history.",
    note: "Explain the cause",
  },
];

const safetySteps = [
  { icon: ScanSearch, title: "Audit", copy: "Measure the live filesystem without changing it." },
  { icon: Binary, title: "Explain", copy: "Separate measured facts from AI judgment." },
  { icon: Fingerprint, title: "Confirm", copy: "Name every exact destructive target." },
  { icon: HardDriveDownload, title: "Act", copy: "Delete, move, compress, or uninstall." },
  { icon: CopyCheck, title: "Verify", copy: "Prove the expected result actually happened." },
];

const comparison = [
  { capability: "Known cache cleanup", conventional: "Scan known temporary paths", storageclean: "Planned baseline" },
  { capability: "Explain why space grew", conventional: "Report size and category", storageclean: "Planned cause tracing" },
  { capability: "Protect the only copy", conventional: "Requires manual judgment", storageclean: "Planned decision input" },
  { capability: "Actions beyond delete", conventional: "Varies by tool", storageclean: "Planned move, compress, uninstall" },
  { capability: "Verify completed work", conventional: "Varies by tool", storageclean: "Planned evidence step" },
];

const windowsDownloadUrl =
  "https://github.com/adamtpang/storageclean.app/releases/download/v0.3.0-beta.1/StorageClean-Setup-0.3.0-beta.1-win-x64.exe";

function BrandMark() {
  return (
    <span className="grid size-9 grid-cols-3 items-end gap-0.5 rounded-lg bg-primary p-2 text-primary-foreground" aria-hidden="true">
      <span className="h-2 rounded-sm bg-current opacity-60" />
      <span className="h-3.5 rounded-sm bg-current opacity-80" />
      <span className="h-5 rounded-sm bg-current" />
    </span>
  );
}

function SectionHeading({ eyebrow, title, copy }: { eyebrow: string; title: string; copy: string }) {
  return (
    <div className="max-w-3xl">
      <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">{eyebrow}</p>
      <h2 className="mt-4 text-balance text-3xl font-semibold tracking-[-0.035em] sm:text-4xl">{title}</h2>
      <p className="mt-5 max-w-2xl text-base leading-7 text-muted-foreground">{copy}</p>
    </div>
  );
}

function WindowsDownloadButton({ filled = false }: { filled?: boolean }) {
  return (
    <a
      href={windowsDownloadUrl}
      className={`focus-ring inline-flex min-h-11 items-center justify-center gap-2 rounded-md px-5 text-sm font-semibold transition-colors duration-100 ease-out active:translate-y-px ${
        filled
          ? "bg-primary text-primary-foreground hover:bg-primary/90"
          : "border border-primary/25 bg-primary/5 text-primary hover:bg-primary/10"
      }`}
    >
      <MonitorDown aria-hidden="true" className="size-4 -translate-y-px" strokeWidth={1.8} />
      Download Windows beta
    </a>
  );
}

export default function Home() {
  return (
    <main className="page-shell min-h-screen overflow-x-clip">
      <header className="sticky top-0 z-50 border-b border-border/80 bg-background/80 backdrop-blur-xl">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 md:px-6 lg:px-8">
          <a href="#top" className="focus-ring inline-flex min-h-11 items-center gap-3 rounded-md pr-2" aria-label="storageclean.app home">
            <BrandMark />
            <span className="text-sm font-semibold tracking-tight">storageclean.app</span>
          </a>

          <nav className="hidden items-center gap-6 text-sm text-muted-foreground md:flex" aria-label="Primary navigation">
            <a className="focus-ring inline-flex min-h-11 items-center rounded-md px-1 py-2 transition-colors duration-100 ease-out hover:text-foreground" href="#audit">
              Audit
            </a>
            <a className="focus-ring inline-flex min-h-11 items-center rounded-md px-1 py-2 transition-colors duration-100 ease-out hover:text-foreground" href="#difference">
              Difference
            </a>
            <a className="focus-ring inline-flex min-h-11 items-center rounded-md px-1 py-2 transition-colors duration-100 ease-out hover:text-foreground" href="#safety">
              Safety
            </a>
          </nav>

          <div className="flex items-center gap-2">
            <a
              href="#audit"
              className="focus-ring hidden min-h-10 items-center justify-center rounded-md bg-primary px-4 text-sm font-semibold text-primary-foreground transition-colors duration-100 ease-out hover:bg-primary/90 active:translate-y-px sm:inline-flex"
            >
              See the audit
            </a>
            <ThemeToggle />
          </div>
        </div>
      </header>

      <section id="top" className="relative">
        <div className="mx-auto grid max-w-7xl gap-14 px-4 pb-16 pt-16 md:px-6 md:pb-24 md:pt-24 lg:grid-cols-[0.9fr_1.1fr] lg:items-center lg:px-8 lg:pb-28 lg:pt-28">
          <div>
            <div className="inline-flex min-h-10 items-center gap-2 rounded-full border border-border bg-card/80 px-3 text-xs font-semibold text-muted-foreground">
              <span className="size-1.5 rounded-full bg-success" aria-hidden="true" />
              Read-only Windows beta available
            </div>

            <h1 className="mt-7 max-w-3xl text-balance text-5xl font-semibold leading-[0.98] tracking-[-0.055em] sm:text-6xl lg:text-7xl">
              Your disk is not full of junk.
              <span className="block text-primary">It is full of decisions.</span>
            </h1>

            <p className="mt-7 max-w-xl text-base leading-7 text-muted-foreground sm:text-lg sm:leading-8">
              storageclean is being designed to explain why space grew, identify what cannot be replaced, and recommend a verifiable next action. Deterministic scanning handles facts. A planned AI layer helps with judgment.
            </p>

            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <a
                href="#audit"
                className="focus-ring inline-flex min-h-11 items-center justify-center gap-2 rounded-md bg-primary px-5 text-sm font-semibold text-primary-foreground transition-colors duration-100 ease-out hover:bg-primary/90 active:translate-y-px"
              >
                Explore the audit
                <ArrowRight aria-hidden="true" className="size-4 -translate-y-px" strokeWidth={1.8} />
              </a>
              <WindowsDownloadButton />
              <a
                href="#safety"
                className="focus-ring inline-flex min-h-11 items-center justify-center gap-2 rounded-md border border-border bg-card px-5 text-sm font-semibold transition-colors duration-100 ease-out hover:bg-accent active:translate-y-px"
              >
                Read the safety model
                <ShieldCheck aria-hidden="true" className="size-4 -translate-y-px" strokeWidth={1.8} />
              </a>
            </div>

            <div className="mt-9 grid max-w-xl grid-cols-1 gap-3 text-xs text-muted-foreground sm:grid-cols-3">
              {[
                [LockKeyhole, "Local-first plan"],
                [Fingerprint, "Exact confirmation"],
                [CopyCheck, "Result verification"],
              ].map(([Icon, label]) => {
                const ItemIcon = Icon as typeof LockKeyhole;
                return (
                  <div key={label as string} className="flex items-center gap-2">
                    <ItemIcon aria-hidden="true" className="size-4 text-primary" strokeWidth={1.8} />
                    <span>{label as string}</span>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="relative lg:pl-4">
            <div className="absolute -inset-8 -z-10 rounded-full bg-primary/10 blur-3xl" aria-hidden="true" />
            <StorageShowcase />
          </div>
        </div>
      </section>

      <section className="border-y border-border bg-card/55">
        <div className="mx-auto grid max-w-7xl divide-y divide-border px-4 md:grid-cols-3 md:divide-x md:divide-y-0 md:px-6 lg:px-8">
          {proofPoints.map((point) => (
            <div key={point.value} className="py-7 md:px-7 md:first:pl-0 md:last:pr-0">
              <p className="font-mono text-2xl font-semibold tracking-tight tabular-nums">{point.value}</p>
              <p className="mt-2 text-sm font-semibold">{point.label}</p>
              <p className="mt-1 text-xs leading-5 text-muted-foreground">{point.detail}</p>
            </div>
          ))}
        </div>
      </section>

      <section id="audit" className="scroll-mt-24 py-20 md:py-28">
        <div className="mx-auto max-w-7xl px-4 md:px-6 lg:px-8">
          <SectionHeading
            eyebrow="The power law"
            title="Find the few decisions that change everything."
            copy="A drive can contain millions of files, but the recovery usually concentrates in a handful of folders, applications, or repeated structures. Rank those first, then decide what each one means."
          />

          <div className="mt-12 grid gap-4 lg:grid-cols-[1.15fr_0.85fr]">
            <div className="rounded-xl border border-border bg-card p-5 sm:p-7">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">Laptop user data</p>
                  <p className="mt-2 font-mono text-3xl font-semibold tabular-nums">{laptopAudit.headline.replace(" measured", "")}</p>
                </div>
                <span className="rounded-full bg-warning-soft px-3 py-1.5 font-mono text-xs font-semibold text-warning">{laptopAudit.topShare} in four</span>
              </div>

              <div className="mt-8 grid gap-4 sm:grid-cols-2">
                {laptopAudit.items.slice(0, 4).map((folder) => (
                  <div key={folder.label} className="rounded-lg bg-muted p-4">
                    <div className="flex items-center justify-between gap-4">
                      <span className="text-sm font-semibold">{folder.label}</span>
                      <span className="font-mono text-xs tabular-nums text-muted-foreground">{folder.share}</span>
                    </div>
                    <p className="mt-5 font-mono text-lg font-semibold tabular-nums">{folder.display}</p>
                    <div className="mt-3 h-1.5 overflow-hidden rounded-full bg-background">
                      <div className="hairline-gradient h-full rounded-full" style={{ width: `${(folder.value / laptopTopMax) * 100}%` }} />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="grid gap-4">
              <div className="rounded-xl border border-border bg-card p-6">
                <div className="flex items-center gap-3">
                  <span className="inline-flex size-10 items-center justify-center rounded-lg bg-success-soft text-success">
                    <Gauge aria-hidden="true" className="size-5" strokeWidth={1.8} />
                  </span>
                  <div>
                    <p className="text-sm font-semibold">Explain sudden growth</p>
                    <p className="mt-1 text-xs text-muted-foreground">System growth, cache regrowth, and duplicate work</p>
                  </div>
                </div>
                <p className="mt-6 text-sm leading-6 text-muted-foreground">
                  A folder total says what is large. A cause chain says why today is different from yesterday and whether cleanup will hold.
                </p>
              </div>

              <div className="rounded-xl border border-border bg-card p-6">
                <div className="flex items-center gap-3">
                  <span className="inline-flex size-10 items-center justify-center rounded-lg bg-warning-soft text-warning">
                    <CircleGauge aria-hidden="true" className="size-5" strokeWidth={1.8} />
                  </span>
                  <div>
                    <p className="text-sm font-semibold">Separate recovery from risk</p>
                    <p className="mt-1 text-xs text-muted-foreground">Large does not mean disposable</p>
                  </div>
                </div>
                <p className="mt-6 text-sm leading-6 text-muted-foreground">
                  Pictures and Videos may dominate storage while containing the only copy. Surface that fact before offering an action.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="difference" className="scroll-mt-24 border-y border-border bg-card/45 py-20 md:py-28">
        <div className="mx-auto max-w-7xl px-4 md:px-6 lg:px-8">
          <SectionHeading
            eyebrow="Three structural wedges"
            title="Pattern matching finds files. Context finds the right move."
            copy="Conventional cleaners are strong at deterministic cache paths. This concept adds a decision layer for cases where file type alone is not enough."
          />

          <div className="mt-12 grid gap-4 lg:grid-cols-3">
            {wedges.map((wedge) => {
              const Icon = wedge.icon;
              return (
                <article key={wedge.title} className="group rounded-xl border border-border bg-card p-6">
                  <div className="flex items-center justify-between gap-4">
                    <span className="inline-flex size-11 items-center justify-center rounded-lg bg-accent text-primary">
                      <Icon aria-hidden="true" className="size-5" strokeWidth={1.8} />
                    </span>
                    <span className="font-mono text-xs text-muted-foreground">{wedge.note}</span>
                  </div>
                  <p className="mt-8 text-xs font-semibold uppercase tracking-[0.14em] text-primary">{wedge.label}</p>
                  <h3 className="mt-3 text-xl font-semibold tracking-tight">{wedge.title}</h3>
                  <p className="mt-4 text-sm leading-6 text-muted-foreground">{wedge.copy}</p>
                </article>
              );
            })}
          </div>
        </div>
      </section>

      <section id="safety" className="scroll-mt-24 py-20 md:py-28">
        <div className="mx-auto max-w-7xl px-4 md:px-6 lg:px-8">
          <div className="grid gap-12 lg:grid-cols-[0.72fr_1.28fr] lg:items-start">
            <SectionHeading
              eyebrow="Safety is the product"
              title="A cleaner should earn the right to delete."
              copy="AI can recommend. It cannot blur the line between a measured fact, a proposed action, user approval, execution, and verification. Those states remain visible."
            />

            <div className="action-step relative grid gap-5 md:grid-cols-5">
              {safetySteps.map((step, index) => {
                const Icon = step.icon;
                return (
                  <div key={step.title} className="relative grid grid-cols-[40px_1fr] gap-4 md:block md:text-center">
                    <span className="relative z-10 inline-flex size-10 items-center justify-center rounded-full border border-border bg-card font-mono text-xs font-semibold text-primary shadow-sm md:mx-auto">
                      <Icon aria-hidden="true" className="size-4" strokeWidth={1.8} />
                    </span>
                    <div className="md:mt-4">
                      <p className="text-sm font-semibold">
                        <span className="sr-only">Step {index + 1}: </span>
                        {step.title}
                      </p>
                      <p className="mt-1 text-xs leading-5 text-muted-foreground">{step.copy}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="mt-14 rounded-xl border border-border bg-card p-5 sm:p-7">
            <div className="grid gap-6 lg:grid-cols-[0.78fr_1.22fr] lg:items-center">
              <div>
                <div className="flex items-center gap-2 text-success">
                  <ShieldCheck aria-hidden="true" className="size-4" strokeWidth={1.8} />
                  <p className="text-xs font-semibold uppercase tracking-[0.14em]">Exact-target doctrine</p>
                </div>
                <h3 className="mt-4 text-2xl font-semibold tracking-tight">Nothing destructive hides behind “clean.”</h3>
                <p className="mt-4 text-sm leading-6 text-muted-foreground">
                  The user sees the path, size, reason, exclusions, reversibility, and verification plan before confirming. Quarantine wins when deletion is not necessary.
                </p>
              </div>

              <div className="rounded-lg bg-muted p-4 font-mono text-xs leading-6 sm:p-5">
                <p className="text-muted-foreground">PROPOSED ACTION</p>
                <p className="mt-3 break-all text-foreground">C:\Users\you\AppData\Local\Temp\example-cache</p>
                <div className="mt-4 grid gap-3 sm:grid-cols-3">
                  <div><p className="text-muted-foreground">Estimated</p><p className="mt-1 font-semibold">About 10 GiB</p></div>
                  <div><p className="text-muted-foreground">Risk</p><p className="mt-1 font-semibold">Temporary</p></div>
                  <div><p className="text-muted-foreground">Verify</p><p className="mt-1 font-semibold">Path absent</p></div>
                </div>
                <div className="mt-5 flex items-center gap-2 text-success">
                  <Check aria-hidden="true" className="size-4" strokeWidth={2} />
                  <span>Games and personal media excluded</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="border-y border-border bg-card/45 py-20 md:py-28">
        <div className="mx-auto max-w-7xl px-4 md:px-6 lg:px-8">
          <div className="grid gap-10 lg:grid-cols-[0.72fr_1.28fr] lg:items-start">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.16em] text-primary">Product direction</p>
              <h2 className="mt-4 text-balance text-3xl font-semibold tracking-[-0.035em] sm:text-4xl">Known-path cleanup is fast. The hard part is deciding what happens next.</h2>
              <p className="mt-5 text-base leading-7 text-muted-foreground">
                Conventional cleanup tools are good at known temporary paths. This prototype explores a decision layer for cause, intent, irreplaceability, and proof.
              </p>
            </div>

            <div className="focus-ring overflow-x-auto rounded-xl border border-border bg-card" role="region" aria-label="Product direction comparison" tabIndex={0}>
              <table className="w-full min-w-[640px] border-collapse text-left text-sm">
                <thead>
                  <tr className="border-b border-border bg-muted/60">
                    <th scope="col" className="px-5 py-4 font-semibold">Capability</th>
                    <th scope="col" className="px-5 py-4 font-semibold">Conventional cleanup</th>
                    <th scope="col" className="px-5 py-4 font-semibold text-primary">storageclean plan</th>
                  </tr>
                </thead>
                <tbody>
                  {comparison.map((row) => (
                    <tr key={row.capability} className="border-b border-border last:border-b-0">
                      <th scope="row" className="px-5 py-4 font-medium">{row.capability}</th>
                      <td className="px-5 py-4 text-muted-foreground">{row.conventional}</td>
                      <td className="px-5 py-4 font-medium">{row.storageclean}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </section>

      <section className="py-20 md:py-28">
        <div className="mx-auto max-w-5xl px-4 md:px-6 lg:px-8">
          <div className="relative overflow-hidden rounded-2xl border border-border bg-card p-7 sm:p-10 lg:p-14">
            <div className="absolute inset-x-0 top-0 h-1 hairline-gradient" aria-hidden="true" />
            <div className="absolute -right-20 -top-24 size-72 rounded-full bg-primary/10 blur-3xl" aria-hidden="true" />
            <div className="relative grid gap-8 lg:grid-cols-[1fr_auto] lg:items-end">
              <div>
                <div className="flex items-center gap-2 text-primary">
                  <Sparkles aria-hidden="true" className="size-4" strokeWidth={1.8} />
                  <p className="text-xs font-semibold uppercase tracking-[0.14em]">Read-only desktop beta</p>
                </div>
                <h2 className="mt-5 max-w-3xl text-balance text-3xl font-semibold tracking-[-0.04em] sm:text-5xl">
                  Clear space without losing the reason you kept it.
                </h2>
                <p className="mt-5 max-w-2xl text-base leading-7 text-muted-foreground">
                  Designed around lessons from hands-on storage audits: recurring growth, concentrated usage, and files whose value cannot be inferred from an extension.
                </p>
              </div>
              <WindowsDownloadButton filled />
            </div>
          </div>
        </div>
      </section>

      <footer className="border-t border-border bg-background/70">
        <div className="mx-auto flex max-w-7xl flex-col gap-5 px-4 py-8 text-xs text-muted-foreground sm:flex-row sm:items-center sm:justify-between md:px-6 lg:px-8">
          <div className="flex items-center gap-3">
            <BrandMark />
            <div>
              <p className="font-semibold text-foreground">storageclean.app</p>
              <p className="mt-1">Audit first. Confirm exact targets. Verify every result.</p>
            </div>
          </div>
          <div className="flex items-center gap-2 font-mono tabular-nums">
            <Layers3 aria-hidden="true" className="size-4" strokeWidth={1.8} />
            <span>Windows read-only beta · v0.3.0</span>
          </div>
        </div>
      </footer>
    </main>
  );
}
