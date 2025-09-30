'use client';

import { useState } from 'react';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Ticket, Calendar, Users, DollarSign, Shield, Check, ArrowUpRight } from 'lucide-react';
import Link from 'next/link';
import { CONTRACTS } from '@/lib/contracts';
import { parseEther } from 'viem';
import { Header } from '@/components/Header';
import { LoadingSpinner } from '@/components/LoadingSpinner';

export default function CreateEventPage() {
  const { address } = useAccount();
  const [formData, setFormData] = useState({
    name: '',
    maxTickets: '',
    price: '',
    eventDate: '',
    maxTransfers: '3',
  });

  const { writeContract, data: hash } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!address) return;

    const eventTimestamp = Math.floor(new Date(formData.eventDate).getTime() / 1000);

    writeContract({
      ...CONTRACTS.EVENT_TICKET,
      functionName: 'createEvent',
      args: [
        formData.name,
        BigInt(formData.maxTickets),
        parseEther(formData.price),
        BigInt(eventTimestamp),
        BigInt(formData.maxTransfers),
      ],
    });
  };

  if (!address) {
    return (
      <div className="min-h-screen bg-slate-950 text-white flex items-center justify-center px-4">
        <div className="max-w-md text-center space-y-6">
          <Ticket className="h-12 w-12 mx-auto text-slate-300" />
          <div className="space-y-2">
            <h2 className="text-2xl font-semibold">Connect your wallet</h2>
            <p className="text-slate-400 text-sm">
              Create and manage events by linking a Reactive Network compatible wallet. RainbowKit supports MetaMask, WalletConnect, and more.
            </p>
          </div>
          <ConnectButton />
        </div>
      </div>
    );
  }

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-slate-950 text-white flex items-center justify-center px-4">
        <div className="max-w-md text-center space-y-6">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full border border-green-500/40 bg-green-500/10">
            <Check className="h-6 w-6 text-green-400" />
          </div>
          <div className="space-y-2">
            <h2 className="text-2xl font-semibold">Event created</h2>
            <p className="text-slate-400 text-sm">
              Your event is now active. Tickets can be minted immediately by your community.
            </p>
          </div>
          <Link
            href="/events"
            className="inline-flex items-center justify-center gap-2 rounded-full border border-white/20 px-6 py-3 text-sm font-semibold text-white transition-colors hover:border-white/40"
          >
            View listings
            <ArrowUpRight className="h-4 w-4" />
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-950 text-white">
      <Header />

      <main className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="space-y-6 text-left md:text-center">
          <div className="flex items-center gap-3 text-xs font-medium tracking-[0.3em] uppercase text-slate-500 md:justify-center">
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
            <span>Organizer studio</span>
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
          </div>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-semibold text-slate-100">
            Publish an event with built-in transfer ceilings and automated monitoring.
          </h1>
          <p className="text-slate-400 text-base md:text-lg max-w-2xl mx-auto">
            Configure capacity, pricing, and transfer allowances in minutes. Reactive Network handles the rest.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-16 space-y-8">
          <div className="rounded-xl border border-white/12 bg-slate-950/60 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)]">
            <label className="block space-y-3">
              <span className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Event name</span>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full rounded-lg border border-slate-800 bg-slate-900 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-white/40 focus:outline-none"
                placeholder="Web3 Conference 2025"
                required
              />
            </label>
          </div>

          <div className="grid gap-6 md:grid-cols-2">
            <div className="rounded-xl border border-white/12 bg-slate-950/60 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)]">
              <label className="block space-y-3">
                <span className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Max tickets</span>
                <input
                  type="number"
                  value={formData.maxTickets}
                  onChange={(e) => setFormData({ ...formData, maxTickets: e.target.value })}
                  className="w-full rounded-lg border border-slate-800 bg-slate-900 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-white/40 focus:outline-none"
                  placeholder="100"
                  required
                />
              </label>
            </div>

            <div className="rounded-xl border border-white/12 bg-slate-950/60 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)]">
              <label className="block space-y-3">
                <span className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Ticket price (ETH)</span>
                <input
                  type="number"
                  step="0.001"
                  value={formData.price}
                  onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                  className="w-full rounded-lg border border-slate-800 bg-slate-900 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-white/40 focus:outline-none"
                  placeholder="0.1"
                  required
                />
              </label>
            </div>
          </div>

          <div className="grid gap-6 md:grid-cols-2">
            <div className="rounded-xl border border-white/12 bg-slate-950/60 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)]">
              <label className="block space-y-3">
                <span className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Event date</span>
                <input
                  type="datetime-local"
                  value={formData.eventDate}
                  onChange={(e) => setFormData({ ...formData, eventDate: e.target.value })}
                  className="w-full rounded-lg border border-slate-800 bg-slate-900 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-white/40 focus:outline-none"
                  required
                />
              </label>
            </div>

            <div className="rounded-xl border border-white/12 bg-slate-950/60 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)]">
              <label className="block space-y-3">
                <span className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-500">Max transfers</span>
                <select
                  value={formData.maxTransfers}
                  onChange={(e) => setFormData({ ...formData, maxTransfers: e.target.value })}
                  className="w-full rounded-lg border border-slate-800 bg-slate-900 px-4 py-3 text-sm text-white focus:border-white/40 focus:outline-none"
                >
                  <option value="1">1 · No resale</option>
                  <option value="2">2 · One resale</option>
                  <option value="3">3 · Two resales</option>
                  <option value="5">5 · Four resales</option>
                </select>
              </label>
            </div>
          </div>

          <div className="rounded-xl border border-white/12 bg-slate-950/60 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)]">
            <h3 className="text-sm font-semibold uppercase tracking-[0.25em] text-slate-500">Anti-scalping defaults</h3>
            <ul className="mt-4 space-y-2 text-sm text-slate-400">
              <li>• Transfer limit capped at {formData.maxTransfers || '3'} moves per ticket</li>
              <li>• Reactive validators audit transfers in real time</li>
              <li>• Transparent on-chain history for every ticket</li>
            </ul>
          </div>

          <button
            type="submit"
            disabled={isConfirming}
            className="inline-flex w-full items-center justify-center gap-2 rounded-full border border-white/20 px-6 py-3 text-sm font-semibold text-white transition-colors hover:border-white/40 disabled:border-slate-800 disabled:text-slate-500"
          >
            {isConfirming ? (
              <>
                <LoadingSpinner size="sm" />
                Creating event…
              </>
            ) : (
              <>
                Publish event
                <ArrowUpRight className="h-4 w-4" />
              </>
            )}
          </button>
        </form>
      </main>
    </div>
  );
}
