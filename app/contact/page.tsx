import type { Metadata } from "next";

import { InfoPage } from "@/components/info-page";
import { operator, repoUrl } from "@/lib/site";

export const metadata: Metadata = {
  title: "Contact | storageclean.app",
  description: "How to reach Adam Pang about storageclean.app and the read-only Windows beta.",
  alternates: { canonical: "/contact" },
};

export default function ContactPage() {
  return (
    <InfoPage eyebrow="Contact" title="Contact storageclean.app">
      <p>
        storageclean.app is operated by {operator.name}. Questions about the storageclean Windows beta, bug reports, and
        feedback on the planned cleanup features can be sent by email to{" "}
        <a href={`mailto:${operator.email}`}>{operator.email}</a>.
      </p>
      <p>
        Bug reports for the storageclean Windows beta can also be filed as issues in the public{" "}
        <a href={`${repoUrl}/issues`}>storageclean.app GitHub repository</a>. Please do not attach a full audit export if it
        contains private folder names you would rather not share.
      </p>
      <p>
        More about the person behind storageclean.app is at <a href={operator.url}>adampang.com</a>.
      </p>
    </InfoPage>
  );
}
