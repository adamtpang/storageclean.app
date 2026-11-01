import type { MetadataRoute } from "next";

import { siteUpdated, siteUrl } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  return ["", "/about", "/contact", "/privacy"].map((path) => ({
    url: `${siteUrl}${path}`,
    lastModified: siteUpdated,
  }));
}
