# A10D Event Ticketing - Frontend

Modern, beautiful web interface for the A10D decentralized event ticketing platform.

## 🎨 Features

- **🎫 Browse Events** - View all available events with real-time ticket availability
- **💳 Buy Tickets** - Purchase NFT tickets directly from the platform
- **📱 My Tickets** - Manage and transfer your owned tickets
- **🎯 Create Events** - Launch events with anti-scalping protection
- **🔐 Web3 Wallet** - Connect with MetaMask, WalletConnect, and more
- **⚡ Real-time Updates** - Live transaction status and confirmations
- **🌙 Dark Mode** - Beautiful dark theme by default
- **📱 Responsive** - Works on desktop, tablet, and mobile

## 🛠️ Tech Stack

- **Next.js 15** - React framework with App Router
- **TypeScript** - Type-safe development
- **Wagmi v2** - React Hooks for Ethereum
- **RainbowKit** - Best-in-class wallet connection
- **Viem** - TypeScript Ethereum library
- **TanStack Query** - Data fetching and caching
- **Tailwind CSS** - Utility-first CSS framework
- **Lucide Icons** - Beautiful, consistent icons

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ or pnpm
- MetaMask or any Web3 wallet
- Test ETH on Sepolia testnet

### Installation

```bash
cd frontend
pnpm install
```

### Configuration

The contract addresses are already configured in `lib/contracts.ts`:

```typescript
EVENT_TICKET: '0x7CF4DA7307AC0213542b6838969058469c412555'
TICKET_CALLBACK: '0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d'
```

### Get a WalletConnect Project ID (Optional but Recommended)

1. Go to https://cloud.walletconnect.com
2. Create a new project
3. Copy your Project ID
4. Update `lib/wagmi.ts`:

```typescript
projectId: 'YOUR_PROJECT_ID_HERE'
```

### Run Development Server

```bash
pnpm dev
```

Open http://localhost:3000 in your browser!

### Build for Production

```bash
pnpm build
pnpm start
```

## 📁 Project Structure

```
frontend/
├── app/
│   ├── layout.tsx          # Root layout with providers
│   ├── page.tsx            # Home page
│   ├── providers.tsx       # Web3 providers setup
│   ├── events/
│   │   └── page.tsx        # Browse and buy tickets
│   ├── my-tickets/
│   │   └── page.tsx        # Manage owned tickets
│   └── create/
│       └── page.tsx        # Create new events
├── lib/
│   ├── contracts.ts        # Contract ABIs and addresses
│   └── wagmi.ts            # Wagmi configuration
└── package.json
```

## 🎯 Key Features

### Home Page (`/`)
- Hero section with platform introduction
- Feature highlights
- Statistics
- Navigation to all pages

### Events Page (`/events`)
- Browse all available events
- See ticket availability in real-time
- Buy tickets with one click
- Automatic price display in ETH
- Transaction status feedback

### My Tickets Page (`/my-tickets`)
- View all owned tickets
- Transfer tickets to other addresses
- Validate tickets at event entrance
- See ticket transfer history

### Create Event Page (`/create`)
- Create new events as an organizer
- Set ticket price, quantity, and date
- Configure anti-scalping parameters
- Choose max transfer limits

## 🔗 Smart Contract Integration

The frontend interacts with two deployed contracts:

### EventTicket Contract
- **Address**: `0x7CF4DA7307AC0213542b6838969058469c412555`
- **Network**: Sepolia Testnet
- **Functions Used**:
  - `createEvent()` - Create new events
  - `mintTicket()` - Buy tickets
  - `transferFrom()` - Transfer tickets
  - `validateTicket()` - Mark ticket as used
  - `events()` - Read event data

### TicketCallback Contract
- **Address**: `0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d`
- **Network**: Sepolia Testnet
- **Purpose**: Receives validation callbacks from Reactive Network

## 🎨 UI Components

### ConnectButton
RainbowKit's beautiful wallet connection button with:
- Multiple wallet options
- Account info display
- Network switching
- ENS support

### Event Cards
Display event information with:
- Event name and ID
- Date and time
- Tickets sold / available
- Price in ETH
- Buy button with transaction status

### Navigation
Consistent navigation across all pages:
- Logo and branding
- Page links
- Wallet connection
- Mobile responsive

## 🌐 Supported Wallets

- MetaMask
- WalletConnect
- Coinbase Wallet
- Rainbow Wallet
- And 100+ more via WalletConnect

## 📱 Responsive Design

The app is fully responsive and works on:
- Desktop (1920px+)
- Laptop (1024px+)
- Tablet (768px+)
- Mobile (375px+)

## 🔧 Development

### Add New Pages

```bash
# Create new route
mkdir app/your-page
touch app/your-page/page.tsx
```

### Add Contract Functions

Update `lib/contracts.ts` with new ABI entries:

```typescript
{
  "type": "function",
  "name": "yourFunction",
  "inputs": [...],
  "outputs": [...],
  "stateMutability": "nonpayable"
}
```

### Read Contract Data

```typescript
const { data } = useReadContract({
  ...CONTRACTS.EVENT_TICKET,
  functionName: 'yourFunction',
  args: [arg1, arg2],
});
```

### Write to Contract

```typescript
const { writeContract } = useWriteContract();

writeContract({
  ...CONTRACTS.EVENT_TICKET,
  functionName: 'yourFunction',
  args: [arg1, arg2],
  value: parseEther('0.1'), // if payable
});
```

## 🐛 Troubleshooting

### Wallet Not Connecting
1. Make sure you're on Sepolia testnet
2. Check browser console for errors
3. Try refreshing the page
4. Clear browser cache

### Transaction Failing
1. Ensure you have enough Sepolia ETH
2. Check gas fees
3. Verify contract address is correct
4. Check if event is still active

### Events Not Loading
1. Verify RPC endpoint is working
2. Check browser console for errors
3. Ensure wallet is connected
4. Try switching networks and back

## 🔗 Links

- **Live Contracts**: https://sepolia.etherscan.io/address/0x7CF4DA7307AC0213542b6838969058469c412555
- **Reactive Network**: https://dev.reactive.network
- **Sepolia Faucet**: https://sepoliafaucet.com

## 🎯 Future Enhancements

- [ ] Event search and filtering
- [ ] Ticket QR codes
- [ ] Event images/thumbnails
- [ ] Price history charts
- [ ] Transfer history timeline
- [ ] Email notifications
- [ ] Calendar integration
- [ ] Social sharing
- [ ] Event categories
- [ ] Featured events section

## 📄 License

MIT License - See parent project for details

## 🤝 Contributing

This is a demo project. For production use, consider:
- Adding error boundaries
- Implementing proper error handling
- Adding unit tests
- Adding E2E tests
- Implementing analytics
- Adding SEO optimization
- Setting up CI/CD

---

**Built with ❤️ using Next.js, Wagmi, and RainbowKit**
