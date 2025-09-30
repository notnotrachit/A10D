'use client';

import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Ticket, Calendar, ShieldCheck, Sparkles } from 'lucide-react';
import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      {/* Navigation */}
      <nav className="border-b border-slate-800 bg-slate-950/50 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-2">
              <Ticket className="h-8 w-8 text-purple-500" />
              <span className="text-xl font-bold bg-gradient-to-r from-purple-400 to-pink-600 bg-clip-text text-transparent">
                A10D Tickets
              </span>
            </div>
            <div className="flex items-center gap-4">
              <Link href="/events" className="text-gray-300 hover:text-white transition-colors">
                Events
              </Link>
              <Link href="/my-tickets" className="text-gray-300 hover:text-white transition-colors">
                My Tickets
              </Link>
              <Link href="/create" className="text-gray-300 hover:text-white transition-colors">
                Create Event
              </Link>
              <ConnectButton />
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="text-center space-y-8">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-400 text-sm">
            <Sparkles className="h-4 w-4" />
            <span>Powered by Reactive Network</span>
          </div>
          
          <h1 className="text-5xl md:text-7xl font-bold bg-gradient-to-r from-white via-gray-200 to-gray-400 bg-clip-text text-transparent">
            Decentralized Event
            <br />
            Ticketing Platform
          </h1>
          
          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Anti-scalping, transparent, and secure. Buy and sell event tickets as NFTs with
            built-in fraud prevention powered by smart contracts.
          </p>

          <div className="flex gap-4 justify-center pt-8">
            <Link
              href="/events"
              className="px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 rounded-lg font-semibold text-white hover:from-purple-700 hover:to-pink-700 transition-all transform hover:scale-105"
            >
              Browse Events
            </Link>
            <Link
              href="/create"
              className="px-8 py-4 bg-slate-800 rounded-lg font-semibold text-white hover:bg-slate-700 transition-all border border-slate-700"
            >
              Create Event
            </Link>
          </div>
        </div>

        {/* Features */}
        <div className="grid md:grid-cols-3 gap-8 mt-32">
          <div className="p-8 rounded-2xl bg-slate-900/50 border border-slate-800 hover:border-purple-500/50 transition-all">
            <div className="h-12 w-12 rounded-lg bg-purple-500/10 flex items-center justify-center mb-4">
              <ShieldCheck className="h-6 w-6 text-purple-500" />
            </div>
            <h3 className="text-xl font-semibold text-white mb-2">Anti-Scalping</h3>
            <p className="text-gray-400">
              Transfer limits and price caps prevent scalpers from profiting unfairly.
            </p>
          </div>

          <div className="p-8 rounded-2xl bg-slate-900/50 border border-slate-800 hover:border-pink-500/50 transition-all">
            <div className="h-12 w-12 rounded-lg bg-pink-500/10 flex items-center justify-center mb-4">
              <Ticket className="h-6 w-6 text-pink-500" />
            </div>
            <h3 className="text-xl font-semibold text-white mb-2">NFT Tickets</h3>
            <p className="text-gray-400">
              Each ticket is a unique NFT that you truly own and can transfer securely.
            </p>
          </div>

          <div className="p-8 rounded-2xl bg-slate-900/50 border border-slate-800 hover:border-blue-500/50 transition-all">
            <div className="h-12 w-12 rounded-lg bg-blue-500/10 flex items-center justify-center mb-4">
              <Calendar className="h-6 w-6 text-blue-500" />
            </div>
            <h3 className="text-xl font-semibold text-white mb-2">Real-time Validation</h3>
            <p className="text-gray-400">
              Reactive Network monitors transfers and validates tickets automatically.
            </p>
          </div>
        </div>

        {/* Stats */}
        <div className="grid md:grid-cols-4 gap-8 mt-20 text-center">
          <div>
            <div className="text-4xl font-bold text-white">100%</div>
            <div className="text-gray-400 mt-2">Transparent</div>
          </div>
          <div>
            <div className="text-4xl font-bold text-white">0</div>
            <div className="text-gray-400 mt-2">Hidden Fees</div>
          </div>
          <div>
            <div className="text-4xl font-bold text-white">3</div>
            <div className="text-gray-400 mt-2">Max Transfers</div>
          </div>
          <div>
            <div className="text-4xl font-bold text-white">24/7</div>
            <div className="text-gray-400 mt-2">Monitoring</div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-800 mt-32">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex justify-between items-center">
            <div className="text-gray-400 text-sm">
              © 2025 A10D. Built on Ethereum Sepolia & Reactive Network.
            </div>
            <div className="flex gap-6">
              <a
                href="https://sepolia.etherscan.io/address/0x7CF4DA7307AC0213542b6838969058469c412555"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-white text-sm transition-colors"
              >
                Contract
              </a>
              <a
                href="https://dev.reactive.network"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-white text-sm transition-colors"
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
