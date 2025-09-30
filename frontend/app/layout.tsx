import type { Metadata } from "next";
import { Inter, Orbitron } from "next/font/google";
import "./globals.css";
import { Providers } from "./providers";
import { BackgroundArtifacts } from "@/components/BackgroundArtifacts";

const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });
const orbitron = Orbitron({ subsets: ["latin"], variable: "--font-orbitron" });

export const metadata: Metadata = {
  title: "A10D - Decentralized Event Ticketing",
  description: "Anti-scalping event ticketing platform powered by Reactive Network",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={`${inter.variable} ${orbitron.variable} relative min-h-screen overflow-x-hidden bg-slate-950 text-white`}>
        <BackgroundArtifacts />
        <div className="relative z-10">
          <Providers>{children}</Providers>
        </div>
      </body>
    </html>
  );
}
