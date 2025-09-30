// Contract addresses and ABIs
export const CONTRACTS = {
  EVENT_TICKET: {
    address: '0x7CF4DA7307AC0213542b6838969058469c412555' as `0x${string}`,
    abi: [
      {
        "type": "constructor",
        "inputs": [],
        "stateMutability": "nonpayable"
      },
      {
        "type": "function",
        "name": "createEvent",
        "inputs": [
          { "name": "_name", "type": "string", "internalType": "string" },
          { "name": "_maxTickets", "type": "uint256", "internalType": "uint256" },
          { "name": "_price", "type": "uint256", "internalType": "uint256" },
          { "name": "_eventDate", "type": "uint256", "internalType": "uint256" },
          { "name": "_maxTransfers", "type": "uint256", "internalType": "uint256" }
        ],
        "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
        "stateMutability": "nonpayable"
      },
      {
        "type": "function",
        "name": "mintTicket",
        "inputs": [
          { "name": "_eventId", "type": "uint256", "internalType": "uint256" },
          { "name": "_tokenURI", "type": "string", "internalType": "string" }
        ],
        "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
        "stateMutability": "payable"
      },
      {
        "type": "function",
        "name": "transferFrom",
        "inputs": [
          { "name": "from", "type": "address", "internalType": "address" },
          { "name": "to", "type": "address", "internalType": "address" },
          { "name": "tokenId", "type": "uint256", "internalType": "uint256" }
        ],
        "outputs": [],
        "stateMutability": "nonpayable"
      },
      {
        "type": "function",
        "name": "validateTicket",
        "inputs": [
          { "name": "_tokenId", "type": "uint256", "internalType": "uint256" }
        ],
        "outputs": [],
        "stateMutability": "nonpayable"
      },
      {
        "type": "function",
        "name": "events",
        "inputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
        "outputs": [
          { "name": "name", "type": "string", "internalType": "string" },
          { "name": "maxTickets", "type": "uint256", "internalType": "uint256" },
          { "name": "ticketsSold", "type": "uint256", "internalType": "uint256" },
          { "name": "pricePerTicket", "type": "uint256", "internalType": "uint256" },
          { "name": "eventDate", "type": "uint256", "internalType": "uint256" },
          { "name": "active", "type": "bool", "internalType": "bool" },
          { "name": "maxTransfersPerTicket", "type": "uint256", "internalType": "uint256" },
          { "name": "organizer", "type": "address", "internalType": "address" }
        ],
        "stateMutability": "view"
      },
      {
        "type": "function",
        "name": "ownerOf",
        "inputs": [{ "name": "tokenId", "type": "uint256", "internalType": "uint256" }],
        "outputs": [{ "name": "", "type": "address", "internalType": "address" }],
        "stateMutability": "view"
      },
      {
        "type": "function",
        "name": "tokenURI",
        "inputs": [{ "name": "tokenId", "type": "uint256", "internalType": "uint256" }],
        "outputs": [{ "name": "", "type": "string", "internalType": "string" }],
        "stateMutability": "view"
      },
      {
        "type": "function",
        "name": "ticketTransferCount",
        "inputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
        "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
        "stateMutability": "view"
      },
      {
        "type": "function",
        "name": "ticketEventId",
        "inputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
        "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
        "stateMutability": "view"
      },
      {
        "type": "function",
        "name": "hasAttended",
        "inputs": [
          { "name": "", "type": "uint256", "internalType": "uint256" },
          { "name": "", "type": "address", "internalType": "address" }
        ],
        "outputs": [{ "name": "", "type": "bool", "internalType": "bool" }],
        "stateMutability": "view"
      },
      {
        "type": "event",
        "name": "EventCreated",
        "inputs": [
          { "name": "eventId", "type": "uint256", "indexed": false },
          { "name": "name", "type": "string", "indexed": false },
          { "name": "maxTickets", "type": "uint256", "indexed": false },
          { "name": "price", "type": "uint256", "indexed": false }
        ],
        "anonymous": false
      },
      {
        "type": "event",
        "name": "TicketMinted",
        "inputs": [
          { "name": "tokenId", "type": "uint256", "indexed": true },
          { "name": "eventId", "type": "uint256", "indexed": true },
          { "name": "buyer", "type": "address", "indexed": true }
        ],
        "anonymous": false
      },
      {
        "type": "event",
        "name": "TicketTransferred",
        "inputs": [
          { "name": "tokenId", "type": "uint256", "indexed": true },
          { "name": "from", "type": "address", "indexed": true },
          { "name": "to", "type": "address", "indexed": true },
          { "name": "transferCount", "type": "uint256", "indexed": false },
          { "name": "maxTransfers", "type": "uint256", "indexed": false }
        ],
        "anonymous": false
      }
    ] as const
  },
  TICKET_CALLBACK: {
    address: '0xE3B386573Af8f8050C7EF24260d2cCcdCE21044d' as `0x${string}`,
  }
};

export const CHAIN_CONFIG = {
  sepolia: {
    id: 11155111,
    name: 'Sepolia',
    network: 'sepolia',
    nativeCurrency: {
      decimals: 18,
      name: 'Ethereum',
      symbol: 'ETH',
    },
    rpcUrls: {
      default: {
        http: ['https://eth-sepolia.public.blastapi.io'],
      },
      public: {
        http: ['https://eth-sepolia.public.blastapi.io'],
      },
    },
    blockExplorers: {
      default: { name: 'Etherscan', url: 'https://sepolia.etherscan.io' },
    },
    testnet: true,
  },
};
