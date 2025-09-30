'use client';

import { useState } from 'react';
import { useReadContract, useWriteContract, useAccount, useWaitForTransactionReceipt } from 'wagmi';
import { formatEther, parseEther } from 'viem';
import { Calendar, Users, Shield, ArrowUpRight } from 'lucide-react';
import { Header } from '@/components/Header';
import { LoadingCard, LoadingPage, LoadingSpinner } from '@/components/LoadingSpinner';
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
    <div className="min-h-screen bg-slate-950 text-white">
      <Header />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="space-y-6 text-left md:text-center">
          <div className="flex items-center gap-3 text-xs font-medium tracking-[0.35em] uppercase text-slate-500 md:justify-center">
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
            <span>Curated Listings</span>
            <span className="h-px w-10 bg-slate-800 hidden md:block" />
          </div>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-semibold text-slate-100">
            Discover events built for crypto-native audiences.
          </h1>
          <p className="text-slate-400 text-base md:text-lg max-w-3xl mx-auto">
            Every listing is powered by verifiable NFT tickets, automatic transfer ceilings, and real-time validation from the Reactive Network.
          </p>
        </div>

        <div className="mt-16 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
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

  // Show loading card while loading
  if (isLoading) {
    console.log(`[Event ${eventId}] Still loading...`);
    return <LoadingCard />;
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
    <div className="flex h-full flex-col justify-between rounded-xl border border-white/12 bg-slate-950/70 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.04)] transition-colors hover:border-white/30">
      <div className="space-y-4">
        <div className="flex items-center justify-between text-xs uppercase tracking-[0.25em] text-slate-500">
          <span>Event {eventId.toString().padStart(2, '0')}</span>
          {soldOut && <span className="text-red-400">Sold out</span>}
        </div>
        <h3 className="text-xl font-semibold text-slate-100">{name}</h3>
        <div className="space-y-2 text-sm text-slate-400">
          <div className="flex items-center gap-2">
            <Calendar className="h-4 w-4" />
            <span>{eventTime.toLocaleDateString()} · {eventTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
          </div>
          <div className="flex items-center gap-2">
            <Users className="h-4 w-4" />
            <span>{sold} / {max} tickets sold</span>
          </div>
          <div className="flex items-center gap-2">
            <Shield className="h-4 w-4" />
            <span>Max {maxTransfers.toString()} transfers</span>
          </div>
        </div>
      </div>

      <div className="mt-8 space-y-4 border-t border-white/10 pt-4">
        <div className="flex items-end justify-between text-sm">
          <span className="text-2xl font-semibold text-slate-100">{formatEther(price)} ETH</span>
          <span className="text-slate-500">{max - sold} remaining</span>
        </div>

        {mintSuccess ? (
          <div className="w-full rounded-full border border-green-500/30 bg-green-500/10 py-3 text-center text-sm font-semibold text-green-400">
            Ticket minted
          </div>
        ) : (
          <button
            onClick={() => onMint(eventId, price)}
            disabled={soldOut || isMinting}
            className="inline-flex w-full items-center justify-center gap-2 rounded-full border border-white/20 px-6 py-3 text-sm font-semibold bg-white cursor-pointer text-black transition-colors hover:border-white/40 disabled:border-slate-800 disabled:text-slate-500 disabled:hover:border-slate-800 disabled:bg-slate-800"
          >
            {isMinting ? (
              <>
                <LoadingSpinner size="sm" />
                Processing…
              </>
            ) : soldOut ? (
              'Sold Out'
            ) : (
              <>
                Buy Ticket
                <ArrowUpRight className="h-4 w-4" />
              </>
            )}
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
