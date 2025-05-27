# Tokenized Supply Chain Interplanetary Commerce

A comprehensive blockchain-based system for managing interplanetary trade and commerce using Clarity smart contracts. This system provides a complete framework for entity verification, trade route management, resource exchange, transportation coordination, and regulatory compliance across planetary boundaries.

## 🚀 Features

### Core Contracts

1. **Entity Verification Contract** (`entity-verification.clar`)
    - Validates interplanetary trade participants
    - Manages entity types (traders, transporters, regulators, exchanges)
    - Tracks reputation and trading history
    - Ensures only verified entities can participate in commerce

2. **Trade Route Contract** (`trade-route.clar`)
    - Manages interplanetary supply chains
    - Defines routes between planets with distance and travel time
    - Controls route access permissions
    - Tracks route status and availability

3. **Resource Exchange Contract** (`resource-exchange.clar`)
    - Facilitates interplanetary resource trading
    - Manages resource balances and deposits
    - Handles buy/sell orders with automated matching
    - Supports multiple resource types (water, oxygen, minerals, energy)

4. **Transportation Coordination Contract** (`transportation.clar`)
    - Manages interplanetary logistics
    - Coordinates shipments between planets
    - Tracks transporter fleet capacity
    - Monitors shipment status from pending to delivery

5. **Regulatory Framework Contract** (`regulatory-framework.clar`)
    - Ensures interplanetary trade regulations
    - Manages planetary authorities and jurisdictions
    - Tracks compliance records and violations
    - Enforces trade limits and restrictions

## 🛠 Technical Architecture

### Smart Contract Design

- **Language**: Clarity (Stacks blockchain)
- **Architecture**: Modular contract system with clear separation of concerns
- **Data Storage**: Efficient map-based storage for scalability
- **Access Control**: Role-based permissions with owner and operator controls

### Key Features

- **Reputation System**: Tracks entity performance and reliability
- **Compliance Monitoring**: Automated regulatory compliance checks
- **Resource Management**: Multi-resource trading with balance tracking
- **Route Optimization**: Efficient interplanetary route management
- **Fleet Coordination**: Transportation capacity and scheduling management

## 📋 Prerequisites

- Stacks blockchain development environment
- Clarity CLI tools
- Node.js and npm for testing
- Vitest for running tests

## 🚀 Getting Started

### Installation

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd interplanetary-commerce
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

### Running Tests

Execute the test suite using Vitest:

\`\`\`bash
npm test
\`\`\`

Run specific test files:
\`\`\`bash
npm test entity-verification.test.ts
npm test trade-route.test.ts
npm test resource-exchange.test.ts
npm test transportation.test.ts
npm test regulatory-framework.test.ts
\`\`\`

### Contract Deployment

1. Deploy contracts to Stacks testnet:
   \`\`\`bash
   clarinet deploy --testnet
   \`\`\`

2. Verify deployment:
   \`\`\`bash
   clarinet console
   \`\`\`

## 📖 Usage Examples

### Entity Verification

\`\`\`clarity
;; Verify a trader entity
(contract-call? .entity-verification verify-entity 'ST1TRADER... u1 "Mars")

;; Check if entity is verified
(contract-call? .entity-verification is-verified 'ST1TRADER...)

;; Update reputation after successful trade
(contract-call? .entity-verification update-reputation 'ST1TRADER... true)
\`\`\`

### Trade Route Management

\`\`\`clarity
;; Create a new trade route
(contract-call? .trade-route create-route "Earth" "Mars" u225000000 u180)

;; Grant access to verified entity
(contract-call? .trade-route grant-route-access u1 'ST1TRADER... u1)

;; Check route availability
(contract-call? .trade-route get-route u1)
\`\`\`

### Resource Trading

\`\`\`clarity
;; Deposit resources for trading
(contract-call? .resource-exchange deposit-resource "water" u1000)

;; Create a sell order
(contract-call? .resource-exchange create-order "water" u100 u10 u2)

;; Fill an existing order
(contract-call? .resource-exchange fill-order u1 u50)
\`\`\`

### Transportation Coordination

\`\`\`clarity
;; Register as a transporter
(contract-call? .transportation register-transporter u1000)

;; Create a shipment
(contract-call? .transportation create-shipment 'ST1RECEIVER... 'ST1TRANSPORTER... u1 "water" u100 u30)

;; Update shipment status
(contract-call? .transportation update-shipment-status u1 u2)
\`\`\`

### Regulatory Compliance

\`\`\`clarity
;; Register planetary authority
(contract-call? .regulatory-framework register-planetary-authority "Mars" 'ST1AUTHORITY... u1)

;; Create regulation
(contract-call? .regulatory-framework create-regulation u1 "water-trade" "Water trading limits")

;; Check compliance
(contract-call? .regulatory-framework check-trade-compliance 'ST1TRADER... "water" u500)
\`\`\`

## 🔧 Configuration

### Environment Variables

- \`STACKS_NETWORK\`: Target network (testnet/mainnet)
- \`DEPLOYER_PRIVATE_KEY\`: Private key for contract deployment
- \`CONTRACT_ADDRESS\`: Deployed contract address

### Contract Parameters

- **Entity Types**: Trader (1), Transporter (2), Regulator (3), Exchange (4)
- **Route Status**: Active (1), Suspended (2), Closed (3)
- **Order Types**: Buy (1), Sell (2)
- **Shipment Status**: Pending (1), In-Transit (2), Delivered (3), Cancelled (4)

## 🧪 Testing

The project includes comprehensive test suites for all contracts:

- **Unit Tests**: Individual function testing
- **Integration Tests**: Cross-contract interaction testing
- **Mock Framework**: Simulated blockchain environment for testing

### Test Coverage

- Entity verification and reputation management
- Trade route creation and access control
- Resource exchange and order matching
- Transportation coordination and fleet management
- Regulatory compliance and enforcement

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: \`git checkout -b feature/new-feature\`
3. Commit changes: \`git commit -am 'Add new feature'\`
4. Push to branch: \`git push origin feature/new-feature\`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🌟 Future Enhancements

- **Cross-Chain Integration**: Support for multiple blockchain networks
- **AI-Powered Route Optimization**: Machine learning for efficient route planning
- **Real-Time Tracking**: IoT integration for shipment monitoring
- **Automated Compliance**: Smart contract-based regulatory enforcement
- **Decentralized Governance**: Community-driven protocol upgrades

## 📞 Support

For questions, issues, or contributions:

- Create an issue on GitHub
- Join our Discord community
- Email: support@interplanetary-commerce.dev

## 🙏 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Clarity language development team
- Interplanetary commerce research community
- Open source contributors and testers

---

**Built for the future of interplanetary commerce** 🚀🌌
