// SPDX-License-Identifier: MIT

// The Solidity version of the contract is set to 0.8.9
pragma solidity ^0.8.9;

// Import ERC20 and Ownable contracts from the OpenZeppelin library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Define the contract named "TikToken" which extends the ERC20 and Ownable contracts using a 24 decimal token
// Depreciated over the 18 decimal contract for maximum wallet compatibility
contract TikToken is ERC20, Ownable {

    // Define several private constants and variables related to the tokenomics of TikToken
    // _maxSupply represents the total supply of TikTokens that will ever exist
    // _initialSupply represents the initial non-owner supply at the time of contract deployment
    // _minReward represents the minimum reward that will be given out for minting tokens
    // _followerSet is how many followers are considered a set, in my initial concept it was 1000
    // _remainingSupply is a rolling value of the remaining TikTokens that can be minted
    // _currentReward represents the current reward that is given for each set of followers
    // _halvingCount keeps track of the number of times the reward has been halved
    // _nextHalving keeps track of the next halving supply amount
    // _allUsersEarn determines whether the follower is rounded up or down to the nearest set of followers
    uint256 private constant _maxSupply = 1 * 10**24;
    uint256 private constant _initialSupply = 0.8192 * 10**24;
    uint256 private constant _minReward = 1;
    uint256 private constant _followerSet = 1000;
    uint256 private constant _rewardReduction = 10;
    uint256 private _remainingSupply = _initialSupply;
    uint256 private _currentReward = 0.00001 * 10**24;
    uint256 private _halvingCount = 1;
    uint256 private _nextHalving = _initialSupply / (2 ** _halvingCount);
    bool private constant _allUsersEarn = true;


    // Mapping to keep track of each unique TikTok user ID that has minted tokens
    mapping(uint256 => bool) private _minted;

    // Contract Events
    event Minted(address account, uint256 amount, uint256 tiktokId, uint256 followers);
    event HalvingOccurred(uint256 halvingCount, uint256 currentReward, uint256 remainingSupply);


    // Constructor function that initializes the TikToken contract
    // Mints initial tokens and sends them to the contract owner
    constructor() ERC20("TikToken", "TIK") {
        uint256 initialMintAmount = _maxSupply - _initialSupply;
        _mint(msg.sender, initialMintAmount);
    }

    function calculateRewards(uint256 followers) private view returns (uint256) {
        uint256 baseReward = _allUsersEarn ? _currentReward : 0; //if all users earn followers get rounded up to the next thousand so even with 0 followers you earn something if not the users with 1 follower set or more will earn
        uint256 amountToMint = (followers / _followerSet) * _currentReward + baseReward; //Rewards calculated based on follower count
        uint256 amountToHalving = _remainingSupply - _nextHalving; //calculates token supply until _nextHalving

        //Ensures a user with too many followers doesn't earn too much unless halving is complete
        if (amountToHalving <= amountToMint && _currentReward > _minReward) {
            amountToMint = amountToHalving; //mint the remaining tokens in this halving cycle
            uint256 rewardedFollowers = amountToMint / _currentReward;
            uint256 remainingFollowers = followers - rewardedFollowers;
            uint256 nextReward = _currentReward / _rewardReduction;
            uint256 nextBase = baseReward / _rewardReduction;
            uint256 rewardMax = _nextHalving / 2;

            uint256 additionalReward = (remainingFollowers / _followerSet) * nextReward + nextBase ; //calculate additional reward for remainingFollowers at the next halving rate

            //ensure the remaining reward doesn't create a double halving event, this will also limit a potential exploit
            if (additionalReward >= rewardMax) {
                additionalReward = rewardMax - _currentReward; //create a buffer of 1 reward until the next halving, unfortunately this user will have rewards capped off, this can only happen to creators with mote than 10M followers.
            }
            amountToMint += additionalReward; //adds the additional reward to the mint amount
        }
        return amountToMint;
    }

    // Mint function allows the owner of the contract to mint tokens
    // It gives out a large amount of tokens to early adopters and gradually reduces the reward as more tokens are minted
    // Each user can earn tokens based on the number of their followers and how many halving cycles have happened
    function mint(address account, uint256 followers, uint256 id) public onlyOwner{

        require(_remainingSupply > 0, "No more tokens to mint"); //Ensures supply exists
        //Skip this iteration if user has already minted tokens or does not have enough followers
            if(_minted[id] || (followers < _followerSet && !_allUsersEarn)){
                return;
            }

        uint256 amountToMint = calculateRewards(followers);

        //reduces supply to remaining supply
        if (_remainingSupply < amountToMint) {
            amountToMint = _remainingSupply;
        }

        //mint the tokens, adjust remaining supply and log the user id
        _mint(account, amountToMint);
        _remainingSupply -= amountToMint;
        _minted[id] = true;
        emit Minted(account, amountToMint, id, followers);

        //performs a halving function, adding a new 0 after the decimal place to the current reward per follower set assuming halving hasn't maxed out.
        if (_remainingSupply <= _nextHalving && _currentReward >= _rewardReduction) {
            _currentReward /= _rewardReduction; 
            _halvingCount++;
            _nextHalving = _initialSupply / (2 ** _halvingCount);
            emit HalvingOccurred(_halvingCount, _currentReward, _remainingSupply);
        }
        if (_currentReward < _minReward) {
            _currentReward = _minReward;
        }
    }

    // Batch mint function allows the contract owner to mint tokens for multiple users at once
    // This function can save gas compared to calling the mint function individually for each user
    function batchMint(address[] calldata accounts, uint256[] calldata followers, uint256[] calldata ids) external onlyOwner {
        require(accounts.length == followers.length, "Mismatched input arrays");
        require(accounts.length == ids.length, "Mismatched input arrays");

        //loop over all items in the batch
        for (uint256 i = 0; i < accounts.length; i++) {

            mint(accounts[i], followers[i], ids[i]);

        }
    }

    // Getter functions to view the remaining supply of tokens, the current reward, the user's minted status, and the number of halvings
    function remainingSupply() external view returns (uint256) {
        return _remainingSupply; //amount of TikTokens remaining to be minted
    }

    function currentReward() external view returns (uint256) {
        return _currentReward; //provides the the reward value per follower set also the minimum reward
    }

    function hasMinted(uint256 id) external view returns (bool) {
        return _minted[id]; //determines if the user has minted already
    }

    function getHalvingCount() external view returns (uint256) {
        return _halvingCount - 1; //provides the actual number of halvings the rewards have gone through
    }

    function getNextHalving() external view returns (uint256) {
        return _nextHalving; //provides the next halving
    }

    
    
    //Should ask my community if I should make this immutable or keep control over this, consider using governance on a future version
    // // Set function allows the owner of the contract to change the _allUsersEarn variable
    // function setAllUsersEarn(bool value) external onlyOwner {
    //     _allUsersEarn = value;
    // }

    // // Set function allows the owner of the contract to change the _followerSet variable
    // function setFollowerSet(uint256 value) external onlyOwner {
    //     _followerSet = value;
    // }

    // Allows me to send the contract to another wallet debating on leaving this out for immutability
    // function transferOwnership(address newOwner) public onlyOwner {
    //     require(newOwner != address(0), "New owner is the zero address");
    //     transferOwnership(newOwner);
    // }

    // Override the decimals function from the ERC20 contract to return a value of 24 instead of the default 18
    function decimals() public view virtual override returns (uint8) {
        return 24;
    }
}