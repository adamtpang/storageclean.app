import type { Metadata } from "next";
import { IBM_Plex_Mono, IBM_Plex_Sans } from "next/font/google";

import { themeInitializer } from "@/lib/theme-script";
import "./globals.css";
import Script from "next/script";

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
        <Script id="posthog-fleet" strategy="afterInteractive">{`(function(){if(window.__posthogFleet)return;window.__posthogFleet=1;var s=document.createElement('script');s.async=true;s.src='https://us-assets.i.posthog.com/static/array.js';s.onload=function(){if(!window.posthog||!window.posthog.init)return;window.posthog.init('phc_FCpCP9mIsb9IcxpX0Qqi6FmJ48sVvscAYIrZmtRHIq4',{api_host:'https://us.i.posthog.com',person_profiles:'identified_only',capture_pageview:'history_change',capture_pageleave:true,autocapture:false,disable_session_recording:true,disable_surveys:true,loaded:function(p){p.register({site:location.hostname})}});};document.head.appendChild(s);})();`}</Script>
        {children}
      </body>
    </html>
  );
}
