# Wallet Server

Wallet Server is a Lua-based server application for managing virtual currency within the Minecraft game using the CC: Tweaked mod. This server application works in conjunction with the Wallet client application to handle user accounts, transactions, and other related functionalities.

## Features
- **User Registration**: Users can register for an account.
- **User Login**: Users can log in to their accounts.
- **Send Currency**: Users can send virtual currency to other users.
- **Balance Management**: The server manages user balances and transactions.
- **Daily Bonus**: Users receive a daily bonus to their account balance.
- **Session Management**: The server handles user sessions securely.

## Requirements

- Minecraft with the CC: Tweaked mod installed.
- A computer with a ender modem to run the Wallet Server application.

## Installation

1. Open the computer in Minecraft.
2. Run the following command to download and run the installer:  
   `wget run https://pinestore.cc/d/128`

## Configuration
The application can be configured by modifying the following variables in the server.lua file:

- `serverName`: The name of the server.  
- `perDayAmount`: The amount of virtual currency given as a daily bonus.
- `disableComputerValidation` in installer.lua to disable validation that computer is not pocket.


## File Structure
`server.lua`: Main server application script.  
`installer.lua`: Script to install the Wallet Server application.


## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgements
[CC: Tweaked](https://modrinth.com/mod/cc-tweaked) - The mod that makes this project possible.  
[Ecnet2](https://github.com/migeyel/ecnet/) - Encrypted networking library.