# Rare Disease Research and Patient Registry System

A comprehensive blockchain-based system built on Stacks using Clarity smart contracts to connect patients with rare diseases to research opportunities, manage consent for health data collection, and provide transparent funding allocation.

## System Overview

This system consists of five interconnected smart contracts that work together to create a transparent, secure, and patient-centric rare disease research ecosystem.

### Core Contracts

1. **Patient Registry Contract** (`patient-registry.clar`)
    - Patient registration and profile management
    - Consent management for data sharing
    - Privacy controls and data access permissions

2. **Research Opportunities Contract** (`research-opportunities.clar`)
    - Research study registration and management
    - Eligibility criteria definition
    - Study status tracking and updates

3. **Matching Engine Contract** (`matching-engine.clar`)
    - Automated patient-study matching based on criteria
    - Consent verification for research participation
    - Match scoring and recommendation system

4. **Funding Allocation Contract** (`funding-allocation.clar`)
    - Transparent funding distribution tracking
    - Grant management and milestone tracking
    - Financial transparency and reporting

5. **Collaboration Hub Contract** (`collaboration-hub.clar`)
    - Inter-institutional collaboration management
    - Data sharing agreements and protocols
    - Global research network coordination

## Key Features

### Patient-Centric Design
- **Consent Management**: Granular control over data sharing and research participation
- **Privacy Protection**: Secure handling of sensitive health information
- **Advocacy Support**: Tools for patient advocacy and treatment access programs

### Research Facilitation
- **Study Matching**: Intelligent matching of patients to relevant research opportunities
- **Global Collaboration**: Seamless coordination between international research institutions
- **Longitudinal Data**: Support for long-term health data collection and analysis

### Transparency & Trust
- **Funding Transparency**: Public tracking of research funding allocation and usage
- **Audit Trail**: Immutable record of all system interactions
- **Decentralized Governance**: Community-driven decision making for system improvements

## Data Types and Structures

### Patient Profile
- Basic demographics and contact information
- Rare disease diagnosis and medical history
- Consent preferences and data sharing settings
- Research participation history

### Research Study
- Study metadata and objectives
- Eligibility criteria and requirements
- Funding information and milestones
- Collaboration partners and institutions

### Matching Criteria
- Disease-specific requirements
- Demographic filters
- Geographic considerations
- Consent level requirements

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Basic understanding of Clarity smart contracts

### Installation
\`\`\`bash
npm install
clarinet check
clarinet test
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

## Contract Interactions

### For Patients
1. Register profile with consent preferences
2. Update medical information and research interests
3. Review and accept/decline research opportunities
4. Track participation history and outcomes

### For Researchers
1. Register research studies with eligibility criteria
2. Access matched patient pools (with consent)
3. Manage study progress and milestones
4. Collaborate with other institutions

### For Institutions
1. Establish collaboration agreements
2. Share resources and data (with proper consent)
3. Track funding allocation and usage
4. Participate in global research networks

## Privacy and Security

- All sensitive data is encrypted and access-controlled
- Patients maintain full control over their data sharing preferences
- Audit trails ensure transparency while protecting privacy
- Compliance with international health data regulations

## Future Enhancements

- Integration with electronic health records (EHRs)
- AI-powered matching algorithms
- Mobile applications for patient engagement
- Integration with clinical trial management systems
- Support for patient-reported outcome measures (PROMs)

## Contributing

This project welcomes contributions from the rare disease research community, patient advocacy groups, and blockchain developers. Please see our contribution guidelines for more information.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
