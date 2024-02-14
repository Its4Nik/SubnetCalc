# Subnet Calculator

This Bash script allows users to calculate network information such as CIDR notation, binary representation, and NetIP for both IPv4 and IPv6 addresses.

## Usage

To use the Subnet Calculator, simply run the script and follow the prompts to input your IPv4 or IPv6 address, as well as the subnet in CIDR notation.

```bash
./subnet_calculator.sh
```

## Features

- Supports both IPv4 and IPv6 addresses.
- Validates input to ensure the correctness of IP addresses and CIDR notation.
- Calculates network information including CIDR notation, binary representation, and NetIP.

## Requirements

- Bash shell environment

## Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/subnet-calculator.git
```

2. Navigate to the directory:

```bash
cd subnet-calculator
```

3. Run the script:

```bash
./subnet_calculator.sh
```

## Examples

### IPv4 Calculation

```bash
Enter your IPv4 or IPv6 address: 192.168.1.1
Please enter your subnet in CIDR Notation: 24
```

### IPv6 Calculation

```bash
Enter your IPv4 or IPv6 address: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
Please enter your subnet in CIDR Notation: 64
```
