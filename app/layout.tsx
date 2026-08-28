import type { Metadata } from "next";
import { IBM_Plex_Mono, IBM_Plex_Sans } from "next/font/google";

import { themeInitializer } from "@/lib/theme-script";
import "./globals.css";

const sans = IBM_Plex_Sans({
  weight: ["400", "500", "600", "700"],
  subsets: ["latin"],
  variable: "--font-ibm-plex-sans",
  display: "swap",
});

const mono = IBM_Plex_Mono({
  weight: "500",
  subsets: ["latin"],
  variable: "--font-ibm-plex-mono",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://storageclean.app"),
  title: "storageclean.app | Understand what is taking space",
  description:
    "An in-development, local-first Windows storage manager designed to explain growth, protect irreplaceable files, and recommend verifiable next actions.",
  openGraph: {
    title: "storageclean.app | Your disk is full of decisions",
    description:
      "Explore a local-first storage manager concept for understanding growth, protecting the only copy, and choosing actions with evidence.",
    type: "website",
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script id="theme-initializer" dangerouslySetInnerHTML={{ __html: themeInitializer }} />
      </head>
      <body className={`${sans.variable} ${mono.variable} antialiased`}>
        {children}
      </body>
    </html>
  );
}
