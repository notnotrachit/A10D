'use client';

import { ArrowUpRight, Calendar, Sparkles } from 'lucide-react';
import Link from 'next/link';
import { Header } from '@/components/Header';

export default function Home() {
  return (
    <div className="min-h-screen bg-slate-950 text-white">
      <Header />

      {/* Hero Section */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="space-y-12 text-left md:text-center">
          <div className="flex items-center gap-3 text-xs font-medium tracking-[0.4em] uppercase text-slate-400 md:justify-center">
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
            <span>Reactive Network Native</span>
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
          </div>

          <h1 className="text-4xl sm:text-5xl md:text-6xl font-semibold text-slate-100 leading-tight md:leading-[1.1]">
            The minimalist ticketing stack for organizers who care about experience.
          </h1>

          <p className="text-lg md:text-xl text-slate-400 max-w-3xl mx-auto leading-relaxed">
            Launch events, sell verifiable NFT tickets, and enforce transfer limits automatically. No clutter, no speculation—just a clean flow from creation to entry.
          </p>

          <div className="flex flex-col sm:flex-row gap-3 md:justify-center pt-2">
            <Link
              href="/events"
              className="inline-flex items-center justify-center gap-2 rounded-full bg-white text-slate-950 px-7 py-3 text-sm font-semibold transition-transform hover:-translate-y-0.5"
            >
              Explore Events
              <ArrowUpRight className="h-4 w-4" />
            </Link>
            <Link
              href="/create"
              className="inline-flex items-center justify-center gap-2 rounded-full border border-slate-800 px-7 py-3 text-sm font-semibold text-slate-200 hover:border-white/30 transition-transform hover:-translate-y-0.5"
            >
              Create an Event
            </Link>
          </div>
        </div>

        <div className="mt-16 grid gap-6 text-sm text-slate-400 md:grid-cols-3">
          <div className="rounded-lg border border-white/12 bg-slate-950/60 px-6 py-4 shadow-[0_0_0_1px_rgba(255,255,255,0.03)]">
            <span className="text-slate-500 uppercase tracking-[0.25em] text-xs">Realtime</span>
            <p className="mt-2 text-2xl font-semibold text-slate-100">Sub-second monitoring with Reactive validators</p>
          </div>
          <div className="rounded-lg border border-white/12 bg-slate-950/60 px-6 py-4 shadow-[0_0_0_1px_rgba(255,255,255,0.03)]">
            <span className="text-slate-500 uppercase tracking-[0.25em] text-xs">Control</span>
            <p className="mt-2 text-2xl font-semibold text-slate-100">Transfer caps & provenance baked into every ticket</p>
          </div>
          <div className="rounded-lg border border-white/12 bg-slate-950/60 px-6 py-4 shadow-[0_0_0_1px_rgba(255,255,255,0.03)]">
            <span className="text-slate-500 uppercase tracking-[0.25em] text-xs">Trustless</span>
            <p className="mt-2 text-2xl font-semibold text-slate-100">Organizer-first workflows with transparent on-chain history</p>
          </div>
        </div>

        {/* Features */}
        <div className="mt-28 grid gap-4 md:grid-cols-3">
          <div className="group rounded-xl border border-white/12 bg-slate-950/60 p-6 transition-colors hover:border-white/30">
            <div className="flex items-center justify-between text-xs uppercase tracking-[0.25em] text-slate-500">
              <span>Tickets</span>
              <span className="text-slate-600 group-hover:text-slate-200">01</span>
            </div>
            <h3 className="mt-6 text-2xl font-semibold text-slate-100">NFT-native access</h3>
            <p className="mt-4 text-sm text-slate-400 leading-relaxed">
              Mint and distribute ERC-721 tickets that mirror real-world access control with verifiable provenance.
            </p>
          </div>

          <div className="group rounded-xl border border-white/12 bg-slate-950/60 p-6 transition-colors hover:border-white/30">
            <div className="flex items-center justify-between text-xs uppercase tracking-[0.25em] text-slate-500">
              <span>Controls</span>
              <span className="text-slate-600 group-hover:text-slate-200">02</span>
            </div>
            <h3 className="mt-6 text-2xl font-semibold text-slate-100">Transfer ceilings</h3>
            <p className="mt-4 text-sm text-slate-400 leading-relaxed">
              Define how many times a ticket can move. Every transfer is counted, enforced, and logged on-chain.
            </p>
          </div>

          <div className="group rounded-xl border border-white/12 bg-slate-950/60 p-6 transition-colors hover:border-white/30">
            <div className="flex items-center justify-between text-xs uppercase tracking-[0.25em] text-slate-500">
              <span>Monitoring</span>
              <span className="text-slate-600 group-hover:text-slate-200">03</span>
            </div>
            <h3 className="mt-6 text-2xl font-semibold text-slate-100">Reactive validators</h3>
            <p className="mt-4 text-sm text-slate-400 leading-relaxed">
              Tap into Reactive Network automation that supervises flows and flags anomalous behaviour instantly.
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-800 mt-32">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
            <div className="text-slate-500 text-sm">
              © 2025 A10D. Built on Ethereum Sepolia & Reactive Network.
            </div>
            <div className="flex gap-6 text-sm">
              <a
                href="https://sepolia.etherscan.io/address/0x7CF4DA7307AC0213542b6838969058469c412555"
                target="_blank"
                rel="noopener noreferrer"
                className="text-slate-500 hover:text-slate-200 transition-colors"
              >
                Contract
              </a>
              <a
                href="https://dev.reactive.network"
                target="_blank"
                rel="noopener noreferrer"
                className="text-slate-500 hover:text-slate-200 transition-colors"
              >
                Docs
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
