'use client';

import Link from 'next/link';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Ticket } from 'lucide-react';

const navItems = [
  { href: '/events', label: 'Events' },
  { href: '/my-tickets', label: 'My Tickets' },
  { href: '/create', label: 'Create Event' },
];

export function Header() {
  return (
    <header className="border-b border-white/15 bg-slate-950/90 backdrop-blur-sm">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-3 text-slate-200 transition-colors hover:text-white">
          <Ticket className="h-6 w-6" />
          <span className="font-display text-sm font-semibold tracking-[0.3em]">A10D</span>
        </Link>
        <nav className="flex items-center gap-6 text-sm text-slate-400">
          {navItems.map((item) => (
            <Link key={item.href} href={item.href} className="transition-colors hover:text-white">
              {item.label}
            </Link>
          ))}
          <ConnectButton />
        </nav>
      </div>
    </header>
  );
}
