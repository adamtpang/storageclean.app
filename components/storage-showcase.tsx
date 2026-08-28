"use client";

import type { CSSProperties } from "react";
import { HardDrive, Laptop, ShieldCheck, Sparkles } from "lucide-react";
import { useMemo, useState } from "react";

import { laptopAudit, ssdAudit } from "@/lib/audit-data";

const datasets = {
  laptop: {
    ...laptopAudit,
    icon: Laptop,
  },
  ssd: {
    ...ssdAudit,
    icon: HardDrive,
  },
} as const;

type DatasetKey = keyof typeof datasets;

export function StorageShowcase() {
  const [selected, setSelected] = useState<DatasetKey>("laptop");
  const dataset = datasets[selected];
  const maxValue = useMemo(() => Math.max(...dataset.items.map((item) => item.value)), [dataset]);
  const DriveIcon = dataset.icon;

  return (
    <div className="glass-panel overflow-hidden rounded-xl border border-border shadow-sm">
      <div className="flex flex-col gap-4 border-b border-border p-4 sm:flex-row sm:items-center sm:justify-between sm:p-6">
        <div className="flex items-center gap-3">
          <span className="inline-flex size-10 items-center justify-center rounded-lg bg-primary text-primary-foreground">
            <DriveIcon aria-hidden="true" className="size-5" strokeWidth={1.8} />
          </span>
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">Illustrative audit model</p>
            <p className="mt-1 font-mono text-sm font-medium tabular-nums">Synthetic, rounded example data</p>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-1 rounded-lg border border-border bg-muted p-1" role="group" aria-label="Choose storage device">
          {(Object.keys(datasets) as DatasetKey[]).map((key) => (
            <button
              key={key}
              type="button"
              aria-pressed={selected === key}
              onClick={() => setSelected(key)}
              className={`focus-ring min-h-11 rounded-md px-3 text-xs font-semibold transition-colors duration-100 ease-out active:translate-y-px ${
                selected === key ? "bg-card text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground"
              }`}
            >
              {key === "laptop" ? "Laptop" : "SSD"}
            </button>
          ))}
        </div>
      </div>

      <div className="grid lg:grid-cols-[1.4fr_0.8fr]">
        <section className="p-4 sm:p-6" aria-live="polite">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-sm font-semibold">{dataset.label}</p>
              <h2 className="mt-1 font-mono text-2xl font-semibold tracking-tight tabular-nums sm:text-3xl">{dataset.headline}</h2>
            </div>
            <p className="max-w-xs text-sm text-muted-foreground sm:text-right">{dataset.subline}</p>
          </div>

          <div className="mt-8 space-y-4">
            {dataset.items.map((item, index) => {
              const style = { "--bar-scale": item.value / maxValue } as CSSProperties;
              const isFree = selected === "ssd" && item.label === "Free";

              return (
                <div key={item.label}>
                  <div className="mb-2 flex items-baseline justify-between gap-4">
                    <div className="flex min-w-0 items-baseline gap-2">
                      <span className="truncate text-sm font-medium">{item.label}</span>
                      <span className="hidden font-mono text-xs tabular-nums text-muted-foreground sm:inline">{item.cumulative}</span>
                    </div>
                    <span className="shrink-0 font-mono text-xs font-medium tabular-nums">{item.display}</span>
                  </div>
                  <div className="h-2 overflow-hidden rounded-full bg-muted">
                    <div
                      className={`data-bar h-full w-full rounded-full ${isFree ? "bg-success" : index < 4 ? "hairline-gradient" : "bg-muted-foreground"}`}
                      style={style}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        <aside className="border-t border-border bg-muted/40 p-4 sm:p-6 lg:border-l lg:border-t-0">
          <div className="flex items-center gap-2 text-success">
            <ShieldCheck aria-hidden="true" className="size-4" strokeWidth={1.8} />
            <p className="text-xs font-semibold uppercase tracking-[0.12em]">Suggested next action</p>
          </div>
          <h3 className="mt-5 text-xl font-semibold tracking-tight">{dataset.action.title}</h3>
          <p className="mt-3 text-sm leading-6 text-muted-foreground">{dataset.action.copy}</p>

          <div className="mt-6 rounded-lg border border-border bg-card p-4">
            <div className="flex items-center justify-between gap-4">
              <span className="text-xs font-medium text-muted-foreground">{dataset.action.metricLabel}</span>
              <Sparkles aria-hidden="true" className="size-4 text-primary" strokeWidth={1.8} />
            </div>
            <p className="mt-2 font-mono text-3xl font-semibold tabular-nums">{dataset.action.metric}</p>
            <p className="mt-2 text-xs leading-5 text-muted-foreground">{dataset.action.detail}</p>
          </div>

          <div className="mt-4 flex items-center gap-2 rounded-lg bg-success-soft px-3 py-2 text-success">
            <span className="size-1.5 rounded-full bg-success" aria-hidden="true" />
            <p className="text-xs font-semibold">Every destructive target requires confirmation.</p>
          </div>
        </aside>
      </div>
    </div>
  );
}
