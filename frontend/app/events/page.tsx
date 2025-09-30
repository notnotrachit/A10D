'use client';

import { useState } from 'react';
import { useReadContract, useWriteContract, useAccount, useWaitForTransactionReceipt } from 'wagmi';
import { formatEther, parseEther } from 'viem';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Ticket, Calendar, Users, Shield, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { CONTRACTS } from '@/lib/contracts';

export default function EventsPage() {
  const { address } = useAccount();
  const [selectedEvent, setSelectedEvent] = useState<number | null>(null);
  const [mintingEventId, setMintingEventId] = useState<number | null>(null);

  const { writeContract, data: hash } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  // Query events 1-20 to show recently created events
  const events = Array.from({ length: 20 }, (_, i) => i + 1);

  console.log('=== Events Page Loaded ===');
  console.log('Connected address:', address);
  console.log('Querying events:', events);
  console.log('Contract address:', CONTRACTS.EVENT_TICKET.address);
  console.log('========================');

  const handleMintTicket = async (eventId: number, price: bigint) => {
    if (!address) return;
    
    setMintingEventId(eventId);
    writeContract({
      ...CONTRACTS.EVENT_TICKET,
      functionName: 'mintTicket',
      args: [BigInt(eventId), `ipfs://ticket-${eventId}-${address}`],
      value: price,
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      {/* Navigation */}
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
          <h1 className="text-4xl font-bold text-white mb-4">Browse Events</h1>
          <p className="text-gray-400">Discover and buy tickets for upcoming events</p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {events.map((eventId) => (
            <EventCard
              key={eventId}
              eventId={eventId}
              onMint={handleMintTicket}
              isMinting={mintingEventId === eventId && isConfirming}
              mintSuccess={mintingEventId === eventId && isSuccess}
            />
          ))}
        </div>

        {/* Show message if no events are rendered */}
        <EventsEmptyState events={events} />
      </main>
    </div>
  );
}

function EventCard({
  eventId,
  onMint,
  isMinting,
  mintSuccess,
}: {
  eventId: number;
  onMint: (eventId: number, price: bigint) => void;
  isMinting: boolean;
  mintSuccess: boolean;
}) {
  const { data: eventData, isLoading, isError } = useReadContract({
    ...CONTRACTS.EVENT_TICKET,
    functionName: 'events',
    args: [BigInt(eventId)],
  });

  console.log(`[Event ${eventId}] Query state:`, { isLoading, isError, hasData: !!eventData });

  // Don't render anything while loading
  if (isLoading) {
    console.log(`[Event ${eventId}] Still loading...`);
    return null;
  }

  // Don't render if there's an error or no data
  if (isError) {
    console.log(`[Event ${eventId}] Error occurred`);
    return null;
  }

  if (!eventData) {
    console.log(`[Event ${eventId}] No data returned`);
    return null;
  }

  // The struct returns: name, maxTickets, ticketsSold, pricePerTicket, eventDate, active, maxTransfersPerTicket, organizer
  const [name, maxTickets, ticketsSold, price, eventDate, active, maxTransfers, organizer] = eventData;

  console.log(`[Event ${eventId}] Data:`, {
    eventId,
    name,
    organizer,
    maxTickets: maxTickets.toString(),
    ticketsSold: ticketsSold.toString(),
    price: price.toString(),
    eventDate: eventDate.toString(),
    maxTransfers: maxTransfers.toString(),
    active,
  });

  // Check if event actually exists (name should not be empty and must be active)
  if (!name || name.length === 0) {
    console.log(`[Event ${eventId}] Skipping: Name is empty`);
    return null;
  }
  
  if (!active) {
    console.log(`[Event ${eventId}] Skipping: Not active (active = ${active})`);
    return null;
  }

  console.log(`[Event ${eventId}] ✅ RENDERING EVENT!`);


  const sold = Number(ticketsSold);
  const max = Number(maxTickets);
  const soldOut = sold >= max;
  const eventTime = new Date(Number(eventDate) * 1000);

  return (
    <div className="group p-6 rounded-2xl bg-slate-900/50 border border-slate-800 hover:border-purple-500/50 transition-all">
      <div className="mb-4">
        <div className="flex items-center justify-between mb-2">
          <span className="px-3 py-1 rounded-full bg-purple-500/10 text-purple-400 text-xs font-semibold">
            Event #{eventId.toString()}
          </span>
          {soldOut && (
            <span className="px-3 py-1 rounded-full bg-red-500/10 text-red-400 text-xs font-semibold">
              SOLD OUT
            </span>
          )}
        </div>
        <h3 className="text-xl font-bold text-white mb-2">{name}</h3>
        <div className="space-y-2 text-sm">
          <div className="flex items-center gap-2 text-gray-400">
            <Calendar className="h-4 w-4" />
            <span>{eventTime.toLocaleDateString()} at {eventTime.toLocaleTimeString()}</span>
          </div>
          <div className="flex items-center gap-2 text-gray-400">
            <Users className="h-4 w-4" />
            <span>{sold} / {max} tickets sold</span>
          </div>
          <div className="flex items-center gap-2 text-gray-400">
            <Shield className="h-4 w-4" />
            <span>Max {maxTransfers.toString()} transfers</span>
          </div>
        </div>
      </div>

      <div className="pt-4 border-t border-slate-800">
        <div className="flex items-center justify-between mb-4">
          <span className="text-2xl font-bold text-white">{formatEther(price)} ETH</span>
          <div className="text-right text-sm text-gray-400">
            <div>{max - sold} left</div>
          </div>
        </div>

        {mintSuccess ? (
          <div className="w-full py-3 px-4 rounded-lg bg-green-500/10 border border-green-500/20 text-green-400 text-center font-semibold">
            ✓ Ticket Minted!
          </div>
        ) : (
          <button
            onClick={() => onMint(eventId, price)}
            disabled={soldOut || isMinting}
            className="w-full py-3 px-4 rounded-lg bg-gradient-to-r from-purple-600 to-pink-600 font-semibold text-white hover:from-purple-700 hover:to-pink-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:from-purple-600 disabled:hover:to-pink-600"
          >
            {isMinting ? 'Minting...' : soldOut ? 'Sold Out' : 'Buy Ticket'}
          </button>
        )}
      </div>
    </div>
  );
}

function EventsEmptyState({ events }: { events: number[] }) {
  const [hasCheckedAll, setHasCheckedAll] = useState(false);

  // Simple check to see if we should show the empty state
  // This is a workaround - ideally we'd track if any EventCard rendered
  return null; // For now, we'll always try to show event cards
}
