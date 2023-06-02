TikToken GitHub

This is TikToken, a novelty Web3 token using the blockchain to reward TikTok users based on the number of followers they have. It doesn’t have any value and shouldn’t be traded for real money. It’s intended as a satire and educational project and no value will be locked into this. It’s a 0 value token. 

I am TechnicallyWeb3, primarily a TikTok creator focused on educating people about Web3, Blockchain, AI and future technologies. I have always had a career in tech and though I was good at programming I only ever did it as a hobby. With Web3 on the horizon I had to get involved. To educate people so that they understand how the tech works, this way we can work together to avoid the same mistakes we made with the last version of the Web. 

This contract is going to be the first project I deploy to a mainnet, I plan to deploy June 2nd. This is a learning experience and a novelty for me. However, as I learn I plan to take you on my journey and share all my experiences with you. 

Firstly I was quite frank in the comments of the TikToken.sol smart contract about the shortcomings. I wasn’t a fan of minting all tokens to my wallet and being responsible for distributing them manually. Instead I created a minting function which accepts a wallet address, unique TikTok ID and follower count. This function ties your ID to your wallet and has a public getter function meaning anyone can publicly link your wallet address to your TikTok account, not just me. This is for a specific reason. To be transparent. This way it’s impossible for me to abuse the minting function without immutable proof I did something wrong (although an exploit or bug could cause this also, an investigation can at least be done). Every time a portion of the token is minted the ID gets associated with the wallet. 

Another concequence and a potential feature of this data collection, specifically when tying an address to your ID is the possibly to use a TikTok handle as your public address in wallet software that opts to support this feature using this contract. This could be implimented on any social platform and make crypto adoption easier, a cheap alternative to ENS (when using the Polygon(MATIC) network) using your social media identeties. 

The TikTokenomics:
Max Supply : 1.0 
Decimals: 18
Owner Share 18.08% (initial mint, locked until first halving)
Remaining Max Supply: 0.8192 TIK
Token Halving Cycles: 13
Starting reward: 0.00001 TIK per 1000 followers (rounded up)
Halving Factor: 10
Minimum Reward (@13 halvings): 0.000000000000000001 TIK per 1000 followers (rounded down)

Some cool side effects happen with these tokenomics. Firstly, with a max supply of 1 this project’s token price will be equal to the market cap. This means if the market cap hits over $30k USD (at time of writing) my token price’s value will be higher than BTC!

Because there’s only 1.0 TIK you can calculate your percentage easily by multiplying your balance x 100. For example the initial amount is 0.1808 and percentage is 18.08%

You may notice I locked my tokens up until the first halving which means I cannot sell any tokens until 59% circulation. This means the only way an exchange can get this token is by gaining TikTok followers and mint it themselves or wait until after the first halving. 

The Halving Mechanism

You may be wondering why 18.08% goes to me. Truthfully, cause I wanted to make it easier math. You see 1-0.1808=0.8192. 8192 is a number which halves exactly 13 times until it gets to 1, and also the reward of 0.00001 TIK is 13 decimal places away from the minimum possible token division of 0.000000000000000001 TIK moving 1 decimal place to the left each halving cycle. 

This means that when the remaining supply drops below 0.4096 (or half of the initial remaining supply of 0.8192) the rewards per 1000 followers drops from 0.00001 to 0.000001 TIK per 1000 followers. This is such an aggressive halving cycle there should be enough TIK tokens for decades to come. 

The idea is that we offer more value to those with more followers who are around sooner. So what is 1000 followers worth? Let’s find out. But really I’m giving the tokens away for free, forever! Hopefully this discourages people from buying these tokens. 

Polygon Contract Address: 0x359c3AD611e377e050621Fb3de1C2f4411684E92


REMIX DEFAULT WORKSPACE

Remix default workspace is present when:
i. Remix loads for the very first time 
ii. A new workspace is created with 'Default' template
iii. There are no files existing in the File Explorer

This workspace contains 3 directories:

1. 'contracts': Holds three contracts with increasing levels of complexity.
2. 'scripts': Contains four typescript files to deploy a contract. It is explained below.
3. 'tests': Contains one Solidity test file for 'Ballot' contract & one JS test file for 'Storage' contract.

SCRIPTS

The 'scripts' folder has four typescript files which help to deploy the 'Storage' contract using 'web3.js' and 'ethers.js' libraries.

For the deployment of any other contract, just update the contract's name from 'Storage' to the desired contract and provide constructor arguments accordingly 
in the file `deploy_with_ethers.ts` or  `deploy_with_web3.ts`

In the 'tests' folder there is a script containing Mocha-Chai unit tests for 'Storage' contract.

To run a script, right click on file name in the file explorer and click 'Run'. Remember, Solidity file must already be compiled.
Output from script will appear in remix terminal.

Please note, require/import is supported in a limited manner for Remix supported modules.
For now, modules supported by Remix are ethers, web3, swarmgw, chai, multihashes, remix and hardhat only for hardhat.ethers object/plugin.
For unsupported modules, an error like this will be thrown: '<module_name> module require is not supported by Remix IDE' will be shown.
