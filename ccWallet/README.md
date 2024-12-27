# Wallet

Wallet is a Lua-based application for managing virtual currency within the Minecraft game using the CC: Tweaked mod. This application provides a visual interface for users to log in, register, and send currency to other users.

## Features
- **Login and Registration**: Users can log in or register for an account.
- **Send Currency**: Users can send virtual currency to other users.
- **Balance Display**: Users can view their current balance.
- **View Transactions**: Users can view their transaction history.
- **View history**: Users can view their account login history for improved security.

## Requirements

- At least one existing in-game [server for wallet](https://github.com/Flowelfox/CCWallet/tree/main/ccWalletServer) application
- Minecraft with the CC: Tweaked mod installed.
- A pocket computer with ender modem to run the Wallet application.

## Installation

1. Open pocket computer
2. Run the following command to download and run the installer:  
`wget run https://pinestore.cc/d/127`

## Configuration

The application can be configured by modifying the following variables in the `wallet.lua` file:

- `disableLogging`: Set to `true` to disable logging.
- `disableComputerValidation` in installer.lua to disable validation that computer is pocket with wireless modem.
- Run setupWalletServer.lua to set or change main server for application to use.

## File Structure

- `wallet.lua`: Main application script.
- `installer.lua`: Script to install the Wallet application.
- `setupWalletServer.lua`: Script to set up the wallet server.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgements

[CC: Tweaked](https://modrinth.com/mod/cc-tweaked) - The mod that makes this project possible.  
[Basalt](https://github.com/Pyroxenium/Basalt) - The GUI framework used in this project.  
[Ecnet2](https://github.com/migeyel/ecnet/) - Encrypted networking library.