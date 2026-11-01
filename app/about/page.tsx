import type { Metadata } from "next";

import { InfoPage } from "@/components/info-page";
import { operator, repoUrl, windowsDownloadUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "About | storageclean.app",
  description:
    "Who builds storageclean.app, what the read-only Windows beta does today, and which storage cleanup features are still planned.",
  alternates: { canonical: "/about" },
};

export default function AboutPage() {
  return (
    <InfoPage eyebrow="About" title="About storageclean.app">
      <p>
        storageclean.app is an in-development, local-first Windows storage manager built by{" "}
        <a href={operator.url}>{operator.name}</a>. The project is designed to explain why disk space grew, protect files
        that may be the only copy, and recommend a verifiable delete, move, compress, or uninstall action for each large item.
      </p>
      <h2>What exists today</h2>
      <p>
        The published storageclean Windows beta is read-only. The beta scans one drive or every mounted fixed and removable
        drive, compares used and free capacity, ranks the largest top-level items, and exports the complete audit as JSON. The
        beta does not delete, move, compress, uninstall, deduplicate, or change any file.
      </p>
      <p>
        The storageclean Windows installer is unsigned and is published on{" "}
        <a href={windowsDownloadUrl}>GitHub releases</a>. The source code, release notes, and installer build scripts live in
        the public <a href={repoUrl}>storageclean.app repository</a>.
      </p>
      <h2>What is still planned</h2>
      <p>
        Destructive cleanup, cause tracing for sudden growth, irreplaceability detection, and an AI judgment layer are planned
        storageclean features, not shipped ones. Every planned destructive action will require the user to confirm the exact
        target path before anything changes, followed by a verification step against the filesystem.
      </p>
    </InfoPage>
  );
}
