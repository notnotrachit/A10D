'use client';

import { useState } from 'react';
import { useAccount, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Ticket, ArrowLeft, Calendar, Users, DollarSign, Shield, Check } from 'lucide-react';
import Link from 'next/link';
import { CONTRACTS } from '@/lib/contracts';
import { parseEther } from 'viem';

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
      <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 flex items-center justify-center">
        <div className="text-center">
          <Ticket className="h-16 w-16 text-purple-500 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-4">Connect Your Wallet</h2>
          <p className="text-gray-400 mb-8">Connect your wallet to create an event</p>
          <ConnectButton />
        </div>
      </div>
    );
  }

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 flex items-center justify-center">
        <div className="text-center">
          <div className="h-16 w-16 rounded-full bg-green-500/10 flex items-center justify-center mx-auto mb-4">
            <Check className="h-8 w-8 text-green-500" />
          </div>
          <h2 className="text-2xl font-bold text-white mb-4">Event Created Successfully!</h2>
          <p className="text-gray-400 mb-8">Your event is now live on the platform</p>
          <Link
            href="/events"
            className="inline-flex items-center gap-2 px-6 py-3 bg-purple-600 rounded-lg text-white hover:bg-purple-700 transition-colors"
          >
            View Events
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      <nav className="border-b border-slate-800 bg-slate-950/50 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <Link href="/" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
              <ArrowLeft className="h-5 w-5 text-gray-400" />
              <Ticket className="h-8 w-8 text-purple-500" />
              <span className="text-xl font-bold bg-gradient-to-r from-purple-400 to-pink-600 bg-clip-text text-transparent">
                A10D Tickets
              </span>
            </Link>
            <ConnectButton />
          </div>
        </div>
      </nav>

      <main className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="mb-12">
          <h1 className="text-4xl font-bold text-white mb-4">Create Event</h1>
          <p className="text-gray-400">Launch your event with built-in anti-scalping protection</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="p-6 rounded-2xl bg-slate-900/50 border border-slate-800">
            <label className="block mb-2">
              <span className="text-white font-semibold mb-2 flex items-center gap-2">
                <Ticket className="h-5 w-5 text-purple-500" />
                Event Name
              </span>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white placeholder-gray-500 focus:outline-none focus:border-purple-500"
                placeholder="Web3 Conference 2025"
                required
              />
            </label>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            <div className="p-6 rounded-2xl bg-slate-900/50 border border-slate-800">
              <label className="block">
                <span className="text-white font-semibold mb-2 flex items-center gap-2">
                  <Users className="h-5 w-5 text-purple-500" />
                  Max Tickets
                </span>
                <input
                  type="number"
                  value={formData.maxTickets}
                  onChange={(e) => setFormData({ ...formData, maxTickets: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white placeholder-gray-500 focus:outline-none focus:border-purple-500"
                  placeholder="100"
                  required
                />
              </label>
            </div>

            <div className="p-6 rounded-2xl bg-slate-900/50 border border-slate-800">
              <label className="block">
                <span className="text-white font-semibold mb-2 flex items-center gap-2">
                  <DollarSign className="h-5 w-5 text-purple-500" />
                  Ticket Price (ETH)
                </span>
                <input
                  type="number"
                  step="0.001"
                  value={formData.price}
                  onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white placeholder-gray-500 focus:outline-none focus:border-purple-500"
                  placeholder="0.1"
                  required
                />
              </label>
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            <div className="p-6 rounded-2xl bg-slate-900/50 border border-slate-800">
              <label className="block">
                <span className="text-white font-semibold mb-2 flex items-center gap-2">
                  <Calendar className="h-5 w-5 text-purple-500" />
                  Event Date
                </span>
                <input
                  type="datetime-local"
                  value={formData.eventDate}
                  onChange={(e) => setFormData({ ...formData, eventDate: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white placeholder-gray-500 focus:outline-none focus:border-purple-500"
                  required
                />
              </label>
            </div>

            <div className="p-6 rounded-2xl bg-slate-900/50 border border-slate-800">
              <label className="block">
                <span className="text-white font-semibold mb-2 flex items-center gap-2">
                  <Shield className="h-5 w-5 text-purple-500" />
                  Max Transfers
                </span>
                <select
                  value={formData.maxTransfers}
                  onChange={(e) => setFormData({ ...formData, maxTransfers: e.target.value })}
                  className="w-full px-4 py-3 rounded-lg bg-slate-800 border border-slate-700 text-white focus:outline-none focus:border-purple-500"
                >
                  <option value="1">1 (No resale)</option>
                  <option value="2">2 (One resale)</option>
                  <option value="3">3 (Two resales)</option>
                  <option value="5">5 (Four resales)</option>
                </select>
              </label>
            </div>
          </div>

          <div className="p-6 rounded-2xl bg-purple-500/10 border border-purple-500/20">
            <h3 className="text-white font-semibold mb-2">Anti-Scalping Protection</h3>
            <ul className="text-sm text-gray-400 space-y-1">
              <li>• Tickets are limited to {formData.maxTransfers || '3'} transfers</li>
              <li>• Reactive Network monitors all transfers in real-time</li>
              <li>• Price caps prevent excessive markups</li>
              <li>• All transactions are transparent on-chain</li>
            </ul>
          </div>

          <button
            type="submit"
            disabled={isConfirming}
            className="w-full py-4 px-6 rounded-lg bg-gradient-to-r from-purple-600 to-pink-600 font-semibold text-white hover:from-purple-700 hover:to-pink-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isConfirming ? 'Creating Event...' : 'Create Event'}
          </button>
        </form>
      </main>
    </div>
  );
}
