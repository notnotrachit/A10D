'use client';

import { useState } from 'react';
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Ticket, ArrowLeft, Send, Check, Calendar, Shield } from 'lucide-react';
import Link from 'next/link';
import { CONTRACTS } from '@/lib/contracts';
import { formatEther } from 'viem';

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
      <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 flex items-center justify-center">
        <div className="text-center">
          <Ticket className="h-16 w-16 text-purple-500 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-4">Connect Your Wallet</h2>
          <p className="text-gray-400 mb-8">Connect your wallet to view your tickets</p>
          <ConnectButton />
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

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="mb-12">
          <h1 className="text-4xl font-bold text-white mb-4">My Tickets</h1>
          <p className="text-gray-400">Manage your event tickets</p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
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

  // Only render if user owns this token
  if (isLoading) return null;
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
    <div className="p-6 rounded-2xl bg-slate-900/50 border border-slate-800">
      <div className="flex items-start justify-between mb-4">
        <div>
          <span className="text-xs text-gray-500">Ticket #{tokenId}</span>
          <h3 className="text-xl font-bold text-white">{name}</h3>
        </div>
        <div className="px-3 py-1 rounded-full bg-green-500/10 text-green-400 text-xs font-semibold">
          Active
        </div>
      </div>
      
      <div className="space-y-2 text-sm mb-4">
        <div className="flex items-center gap-2 text-gray-400">
          <Calendar className="h-4 w-4" />
          <span>{new Date(Number(eventDate) * 1000).toLocaleDateString()}</span>
        </div>
        <div className="flex items-center gap-2 text-gray-400">
          <Shield className="h-4 w-4" />
          <span>Max {maxTransfers.toString()} transfers</span>
        </div>
      </div>

      {/* Transaction Status */}
      {isPending && (
        <div className="mb-4 p-3 bg-blue-500/10 border border-blue-500/20 rounded-lg text-blue-400 text-sm">
          ⏳ Waiting for wallet confirmation...
        </div>
      )}
      {isConfirming && (
        <div className="mb-4 p-3 bg-yellow-500/10 border border-yellow-500/20 rounded-lg text-yellow-400 text-sm">
          ⏳ Transaction pending...
        </div>
      )}
      {isSuccess && (
        <div className="mb-4 p-3 bg-green-500/10 border border-green-500/20 rounded-lg text-green-400 text-sm">
          ✅ Transaction confirmed! Refresh to see updates.
        </div>
      )}

      {showTransfer ? (
        <div className="space-y-2">
          <input
            type="text"
            placeholder="Recipient address (0x...)"
            value={recipientAddress}
            onChange={(e) => setRecipientAddress(e.target.value)}
            className="w-full px-3 py-2 bg-slate-800 border border-slate-700 rounded-lg text-white text-sm placeholder-gray-500 focus:outline-none focus:border-purple-500"
          />
          <div className="flex gap-2">
            <button
              onClick={handleTransferClick}
              disabled={isPending || isConfirming}
              className="flex-1 py-2 px-4 bg-purple-600 rounded-lg text-white hover:bg-purple-700 transition-colors text-sm font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isPending || isConfirming ? 'Processing...' : 'Confirm Transfer'}
            </button>
            <button
              onClick={() => setShowTransfer(false)}
              disabled={isPending || isConfirming}
              className="flex-1 py-2 px-4 bg-slate-700 rounded-lg text-white hover:bg-slate-600 transition-colors text-sm disabled:opacity-50"
            >
              Cancel
            </button>
          </div>
        </div>
      ) : (
        <div className="flex gap-2">
          <button
            onClick={() => setShowTransfer(true)}
            disabled={isPending || isConfirming}
            className="w-full py-2 px-4 bg-purple-600 rounded-lg text-white hover:bg-purple-700 transition-colors text-sm font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Send className="h-4 w-4 inline mr-1" />
            Transfer Ticket
          </button>
        </div>
      )}
    </div>
  );
}
