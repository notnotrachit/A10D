'use client';

import { useState } from 'react';
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Ticket, Send, Calendar, Shield } from 'lucide-react';
import Link from 'next/link';
import { CONTRACTS } from '@/lib/contracts';
import { formatEther } from 'viem';
import { Header } from '@/components/Header';
import { LoadingCard, LoadingSpinner } from '@/components/LoadingSpinner';

export default function MyTicketsPage() {
  const { address } = useAccount();
  const [transferTokenId, setTransferTokenId] = useState<number | null>(null);
  const [transferTo, setTransferTo] = useState('');

  const { writeContract, data: hash } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  // Check token IDs 1-50 to see which ones user owns
  const possibleTokenIds = Array.from({ length: 50 }, (_, i) => i + 1);
  const ownedTokens: number[] = [];

  console.log('My Tickets: Checking ownership for address:', address);

  const handleTransfer = (tokenId: number) => {
    if (!address || !transferTo) return;

    writeContract({
      ...CONTRACTS.EVENT_TICKET,
      functionName: 'transferFrom',
      args: [address, transferTo as `0x${string}`, BigInt(tokenId)],
    });
  };

  const handleValidate = (tokenId: number) => {
    writeContract({
      ...CONTRACTS.EVENT_TICKET,
      functionName: 'validateTicket',
      args: [BigInt(tokenId)],
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
              Link a wallet to browse and manage your tickets. We support RainbowKit with MetaMask, WalletConnect, and more.
            </p>
          </div>
          <ConnectButton />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-950 text-white">
      <Header />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="space-y-6 text-left md:text-center">
          <div className="flex items-center gap-3 text-xs font-medium tracking-[0.3em] uppercase text-slate-500 md:justify-center">
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
            <span>Your collection</span>
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
          </div>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-semibold text-slate-100">
            Tickets that unlock every experience you care about.
          </h1>
          <p className="text-slate-400 text-base md:text-lg max-w-3xl mx-auto">
            Track ownership, transfer responsibly, and review ticket status—all within a single minimalist dashboard.
          </p>
        </div>

        <div className="mt-16 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {possibleTokenIds.map((tokenId) => (
            <TicketCard
              key={tokenId}
              tokenId={tokenId}
              ownerAddress={address}
              onTransfer={handleTransfer}
              onValidate={handleValidate}
            />
          ))}
        </div>
      </main>
    </div>
  );
}

// Ticket card component
function TicketCard({ 
  tokenId, 
  ownerAddress,
  onTransfer,
  onValidate 
}: { 
  tokenId: number;
  ownerAddress: `0x${string}`;
  onTransfer: (tokenId: number) => void;
  onValidate: (tokenId: number) => void;
}) {
  const [showTransfer, setShowTransfer] = useState(false);
  const [recipientAddress, setRecipientAddress] = useState('');
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  // Check if this token is owned by the user
  const { data: owner, isLoading } = useReadContract({
    ...CONTRACTS.EVENT_TICKET,
    functionName: 'ownerOf',
    args: [BigInt(tokenId)],
  });

  // Get ticket's event data
  const { data: ticketEventId } = useReadContract({
    ...CONTRACTS.EVENT_TICKET,
    functionName: 'ticketEventId',
    args: [BigInt(tokenId)],
  });

  const { data: eventData } = useReadContract({
    ...CONTRACTS.EVENT_TICKET,
    functionName: 'events',
    args: ticketEventId ? [ticketEventId] : undefined,
    query: { enabled: !!ticketEventId },
  });

  // Show loading card while checking ownership
  if (isLoading) return <LoadingCard />;
  if (!owner || owner.toLowerCase() !== ownerAddress.toLowerCase()) {
    return null;
  }

  console.log(`User owns token #${tokenId}!`);

  if (!eventData) return null;

  const [name, maxTickets, ticketsSold, price, eventDate, active, maxTransfers, organizer] = eventData;

  const handleTransferClick = () => {
    if (!recipientAddress) {
      alert('Please enter a recipient address');
      return;
    }
    writeContract({
      ...CONTRACTS.EVENT_TICKET,
      functionName: 'transferFrom',
      args: [ownerAddress, recipientAddress as `0x${string}`, BigInt(tokenId)],
    });
    setShowTransfer(false);
    setRecipientAddress('');
  };

  const handleValidateClick = () => {
    if (confirm(`Validate ticket #${tokenId}? This action cannot be undone.`)) {
      writeContract({
        ...CONTRACTS.EVENT_TICKET,
        functionName: 'validateTicket',
        args: [BigInt(tokenId)],
      });
    }
  };

  return (
    <div className="flex h-full flex-col justify-between rounded-xl border border-white/12 bg-slate-950/60 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)] transition-colors hover:border-white/30">
      <div className="space-y-3">
        <div className="flex items-center justify-between text-xs uppercase tracking-[0.25em] text-slate-500">
          <span>Ticket {tokenId.toString().padStart(2, '0')}</span>
          <span className="text-slate-600">Active</span>
        </div>
        <h3 className="text-xl font-semibold text-slate-100">{name}</h3>
        <div className="space-y-2 text-sm text-slate-400">
          <div className="flex items-center gap-2">
            <Calendar className="h-4 w-4" />
            <span>{new Date(Number(eventDate) * 1000).toLocaleDateString()}</span>
          </div>
          <div className="flex items-center gap-2">
            <Shield className="h-4 w-4" />
            <span>Max {maxTransfers.toString()} transfers</span>
          </div>
        </div>
      </div>

      <div className="mt-6 space-y-3 text-sm">
        {isPending && (
          <div className="rounded-full border border-blue-400/30 bg-blue-500/10 px-4 py-2 text-center text-blue-300">
            Waiting for wallet confirmation…
          </div>
        )}
        {isConfirming && (
          <div className="rounded-full border border-yellow-400/30 bg-yellow-500/10 px-4 py-2 text-center text-yellow-200">
            Transaction pending…
          </div>
        )}
        {isSuccess && (
          <div className="rounded-full border border-green-500/30 bg-green-500/10 px-4 py-2 text-center text-green-300">
            Transaction confirmed
          </div>
        )}

        {showTransfer ? (
          <div className="space-y-3">
            <input
              type="text"
              placeholder="0xRecipient"
              value={recipientAddress}
              onChange={(e) => setRecipientAddress(e.target.value)}
              className="w-full rounded-full border border-slate-800 bg-slate-900 px-4 py-2 text-sm text-white placeholder-slate-500 focus:border-white/40 focus:outline-none"
            />
            <div className="flex gap-3">
              <button
                onClick={handleTransferClick}
                disabled={isPending || isConfirming}
                className="flex-1 rounded-full border border-white/20 px-4 py-2 text-sm font-semibold text-white transition-colors hover:border-white/40 disabled:border-slate-700 disabled:text-slate-500"
              >
                {isPending || isConfirming ? (
                  <>
                    <LoadingSpinner size="sm" />
                    Processing…
                  </>
                ) : (
                  'Confirm transfer'
                )}
              </button>
              <button
                onClick={() => setShowTransfer(false)}
                disabled={isPending || isConfirming}
                className="flex-1 rounded-full border border-slate-800 px-4 py-2 text-sm font-semibold text-slate-300 hover:border-slate-600 disabled:text-slate-600"
              >
                Cancel
              </button>
            </div>
          </div>
        ) : (
          <button
            onClick={() => setShowTransfer(true)}
            disabled={isPending || isConfirming}
            className="inline-flex w-full items-center justify-center gap-2 rounded-full border border-white/20 px-4 py-2 text-sm font-semibold text-black bg-white transition-colors hover:border-white/40 disabled:border-slate-800 disabled:text-slate-500 disabled:bg-slate-800"
          >
            {isPending || isConfirming ? (
              <>
                <LoadingSpinner size="sm" />
                Processing…
              </>
            ) : (
              <>
                <Send className="h-4 w-4" />
                Start transfer
              </>
            )}
          </button>
        )}
      </div>
    </div>
  );
}
