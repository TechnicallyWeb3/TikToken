// SPDX-License-Identifier: MIT

// The Solidity version of the contract is set to 0.8.9
pragma solidity ^0.8.9;

// Import ERC20 and Ownable contracts from the OpenZeppelin library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the contract named "TikToken" which extends the ERC20 and Ownable contracts
contract TikToken is ERC20, Ownable {

    // Define several private constants and variables related to the tokenomics of TikToken
    // _maxSupply represents the total supply of TikTokens that will ever exist
    // _initialSupply represents the initial non-owner supply at the time of contract deployment
    // _minReward represents the minimum reward that will be given out for minting tokens
    // _remainingSupply is a rolling value of the remaining TikTokens that can be minted
    // _currentReward represents the current reward that is given for each 1000 followers
    // _halvingCount keeps track of the number of times the reward has been halved
    uint256 private constant _maxSupply = 1 * 10**24;
    uint256 private constant _initialSupply = 0.8192 * 10**24;
    uint256 private constant _minReward = 1;
    uint256 private _remainingSupply = _initialSupply;
    uint256 private _currentReward = 0.00001 * 10**24;
    uint256 private _halvingCount = 1;

    // Mapping to keep track of each unique TikTok user ID that has minted tokens
    mapping(uint256 => bool) private _minted;

    // Constructor function that initializes the TikToken contract
    // Mints initial tokens and sends them to the contract owner
    constructor() ERC20("TikToken", "TIK") {
        uint256 initialMintAmount = _maxSupply - _initialSupply;
        _mint(msg.sender, initialMintAmount);
    }

    // Mint function allows the owner of the contract to mint tokens
    // It gives out a large amount of tokens to early adopters and gradually reduces the reward as more tokens are minted
    // Each user can earn tokens based on the number of their followers and how many halving cycles have happened
    function mint(address account, uint256 followers, uint256 id) external onlyOwner{

        require(_remainingSupply > 0, "No more tokens to mint"); //Ensures supply exists
        require(!_minted[id], "User has already minted tokens"); //Checks user hasn't already minted

        uint256 amountToMint = (followers / 1000) * _currentReward + _currentReward; //Rewards calculated based on follower count
        uint256 nextHalving = _initialSupply / (2 ** _halvingCount); //calculates next halving amount
        uint256 amountToHalving = _remainingSupply - nextHalving; //calculates token supply until nextHalving

        //Ensures a user with too many followers doesn't earn too much unless halving is complete
        if (amountToHalving <= amountToMint && _currentReward > _minReward) {
            amountToMint = amountToHalving; //mint the remaining tokens in this halving cycle
            uint256 remainingFollowers = followers - (amountToMint * 1000 / (_currentReward)); //calculate any followers not compensated
            uint256 additionalReward = (remainingFollowers / 1000) * (_currentReward / 2) + (_currentReward / 2) ; //calculate additional reward for remainingFollowers at the next halving rate

            //ensure the remaining reward doesn't create a double halving event
            if (additionalReward >= nextHalving / 2) {
                additionalReward = (nextHalving / 2) - _currentReward; //create a buffer of 1 reward until the next halving, unfortunately this user will have rewards capped off, this can only happen to creators with mote than 10M followers.
            }
            amountToMint += additionalReward; //adds the additional reward to the mint amount
        }

        //reduces supply to remaining supply
        if (_remainingSupply < amountToMint) {
            amountToMint = _remainingSupply;
        }

        //mint the tokens, adjust remaining supply and log the user id
        _mint(account, amountToMint);
        _remainingSupply -= amountToMint;
        _minted[id] = true;

        //performs a halving function, adding a new 0 after the decimal place to the current reward per 1000 followers assuming halving hasn't maxed out.
        if (_remainingSupply <= nextHalving && _currentReward > _minReward) {
            _currentReward /= 10; 
            _halvingCount++;
        }
    }

    // Batch mint function allows the contract owner to mint tokens for multiple users at once
    // This function can save gas compared to calling the mint function individually for each user
    function batchMint(address[] calldata accounts, uint256[] calldata followers, uint256[] calldata ids) external onlyOwner {
        require(accounts.length == followers.length, "Mismatched input arrays");
        require(accounts.length == ids.length, "Mismatched input arrays");

        for (uint256 i = 0; i < accounts.length; i++) {
            require(_remainingSupply > 0, "No more tokens to mint"); //Ensures supply exists
            require(!_minted[ids[i]], "User has already minted tokens"); //Checks user hasn't already minted

            uint256 amountToMint = (followers[i] / 1000) * _currentReward + _currentReward; //Rewards calculated based on follower count
            uint256 nextHalving = _initialSupply / (2 ** _halvingCount); //calculates next halving amount
            uint256 amountToHalving = _remainingSupply - nextHalving; //calculates token supply until nextHalving

            //Ensures a user with too many followers doesn't earn too much unless halving is complete
            if (amountToHalving <= amountToMint && _currentReward > _minReward) {
                amountToMint = amountToHalving; //mint the remaining tokens in this halving cycle
                uint256 remainingFollowers = followers[i] - (amountToMint * 1000 / (_currentReward)); //calculate any followers not compensated
                uint256 additionalReward = (remainingFollowers / 1000) * (_currentReward / 2) + (_currentReward / 2); //calculate additional reward for remainingFollowers at the next halving rate

                //ensure the remaining reward doesn't create a double halving event
                if (additionalReward >= nextHalving / 2) {
                    additionalReward = (nextHalving / 2) - _currentReward; //create a buffer of 1 reward until the next halving, unfortunately this user will have rewards capped off, this can only happen to creators with mote than 10M followers.
                }
                amountToMint += additionalReward; //adds the additional reward to the mint amount
            }

            //reduces supply to remaining supply
            if (_remainingSupply < amountToMint) {
                amountToMint = _remainingSupply;
            }

            //mint the tokens, adjust remaining supply and log the user id
            _mint(accounts[i], amountToMint);
            _remainingSupply -= amountToMint;
            _minted[ids[i]] = true;

            //performs a halving function, adding a new 0 after the decimal place to the current reward per 1000 followers assuming halving hasn't maxed out.
            if (_remainingSupply <= nextHalving && _currentReward > _minReward) {
                _currentReward /= 10; 
                _halvingCount++;
            }
        }
    }

    // Getter functions to view the remaining supply of tokens, the current reward, the user's minted status, and the number of halvings
    function remainingSupply() external view returns (uint256) {
        return _remainingSupply; //amount of TikTokens remaining to be minted
    }

    function currentReward() external view returns (uint256) {
        return _currentReward; //provides the the reward value per 1000 followers also the minimum reward
    }

    function hasMinted(uint256 id) external view returns (bool) {
        return _minted[id]; //determines if the user has minted already
    }

    function getHalvingCount() external view returns (uint256) {
        return _halvingCount - 1; //provides the actual number of halvings the rewards have gone through
    }
    
    // Override the decimals function from the ERC20 contract to return a value of 24 instead of the default 18
    function decimals() public view virtual override returns (uint8) {
        return 24;
    }
}