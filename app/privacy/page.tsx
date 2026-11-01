import type { Metadata } from "next";

import { InfoPage } from "@/components/info-page";
import { operator, siteUpdated, siteUpdatedLabel } from "@/lib/site";

export const metadata: Metadata = {
  title: "Privacy | storageclean.app",
  description:
    "What storageclean.app collects: privacy-respecting PostHog page analytics on the website, and nothing from the read-only Windows beta.",
  alternates: { canonical: "/privacy" },
};

export default function PrivacyPage() {
  return (
    <InfoPage eyebrow="Privacy" title="Privacy policy">
      <p>
        This storageclean.app privacy policy was last updated on <time dateTime={siteUpdated}>{siteUpdatedLabel}</time>. It
        describes what the storageclean.app website and the storageclean Windows beta collect, and which third parties process
        that data. storageclean.app is operated by {operator.name}.
      </p>
      <h2>Website analytics</h2>
      <p>
        The storageclean.app website uses PostHog, hosted in the United States, to count visits. The PostHog script records
        page views and page leaves, including the page address, referrer, browser, device type, and approximate location derived
        from the IP address. PostHog stores an anonymous identifier in a cookie and in local storage so repeat visits can be
        counted. The site does not create a person profile unless you identify yourself, which this site never asks you to do.
      </p>
      <p>
        The PostHog project used by storageclean.app also has Core Web Vitals, heatmaps, and dead click detection enabled. Core
        Web Vitals measure page loading speed, heatmaps record where on the page clicks and scrolls happen, and dead click
        detection notes clicks that did not lead to any change on the page. Automatic click capture of page
        elements, session recording, and surveys are turned off in the storageclean.app site code.
      </p>
      <h2>Hosting and downloads</h2>
      <p>
        The storageclean.app website is hosted on Vercel, which processes standard request logs such as IP address, requested
        URL, and user agent to serve and protect the site. The Windows beta installer is downloaded from GitHub releases, so
        GitHub processes that download request under its own privacy statement.
      </p>
      <h2>The Windows beta</h2>
      <p>
        The storageclean Windows beta runs locally and does not send scan results, file names, or telemetry anywhere. Audit
        exports are written only to a location you choose on your own computer. The only network action in the beta is an
        optional link that opens storageclean.app in your browser.
      </p>
      <h2>Your choices</h2>
      <p>
        The storageclean.app website stores your light or dark theme preference in local storage on your device. You can block
        PostHog with a content blocker or clear its cookie and local storage at any time. To ask about or delete data related to
        storageclean.app, email <a href={`mailto:${operator.email}`}>{operator.email}</a>.
      </p>
    </InfoPage>
  );
}
