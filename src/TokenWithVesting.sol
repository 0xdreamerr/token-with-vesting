// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/* ====== EXTERNAL IMPORTS ====== */

import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";

/* ====== INTERFACES IMPORTS ====== */

/* ====== CONTRACTS IMPORTS ====== */

contract TokenWithVesting is ERC20, Ownable {
    /* ======== STATE ======== */

    uint256 public constant MAX_VESTINGS_PER_ADDRESS = 5;

    struct TokenVesting {
        uint256 amount;
        uint64 start;
        uint64 cliff;
        uint64 vesting;
        bool revokable;
    }

    mapping(address => mapping(uint256 => TokenVesting)) internal vestings;
    mapping(address => uint256) public vestingsLengths;

    modifier vestingExists(address _holder, uint256 _vestingId) {
        require(
            _vestingId < vestingsLengths[_holder],
            NoVesting("Vesting not exist")
        );
        _;
    }

    /* ======== ERRORS ======== */

    error NoVesting(string message);
    error VestingToTM(string message);
    error TooManyVestings(string message);
    error WrongCliffDate(string message);
    error VestingNotRevokable(string message);
    error RevokeTransferFromReverted();
    error NotEnoughUnlockedTokens();

    /* ======== EVENTS ======== */

    event NewVesting(
        address indexed receiver,
        uint256 vestingId,
        uint256 amount
    );
    event RevokeVesting(
        address indexed receiver,
        uint256 vestingId,
        uint256 nonVestedAmount
    );

    /* ======== CONSTRUCTOR AND INIT ======== */

    constructor(
        string memory name,
        string memory symbol,
        uint256 _totalSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        mint(address(this), _totalSupply);
    }

    /* ======== EXTERNAL/PUBLIC ======== */

    /* ======== INTERNAL ======== */

    /* ======== ADMIN ======== */

    function mint(address _receiver, uint256 _amount) public onlyOwner {
        _mint(_receiver, _amount);
    }

    /**
     * @notice Assign `@tokenAmount(self.token(): address, _amount, false)` tokens to `_receiver` from the Token Manager's holdings with a `_revokable ? 'revokable' : ''` vesting starting at `@formatDate(_start)`, cliff at `@formatDate(_cliff)` (first portion of tokens transferable), and completed vesting at `@formatDate(_vested)` (all tokens transferable)
     * @param _receiver The address receiving the tokens, cannot be Token Manager itself
     * @param _amount Number of tokens vested
     * @param _start Date the vesting calculations start
     * @param _cliff Date when the initial portion of tokens are transferable
     * @param _vested Date when all tokens are transferable
     * @param _revokable Whether the vesting can be revoked by the Token Manager
     */
    function assignVested(
        address _receiver,
        uint256 _amount,
        uint64 _start,
        uint64 _cliff,
        uint64 _vested,
        bool _revokable
    ) external onlyOwner returns (uint256) {
        require(
            _receiver != address(this),
            VestingToTM("Vesting to Token Manager")
        );
        require(
            vestingsLengths[_receiver] < MAX_VESTINGS_PER_ADDRESS,
            TooManyVestings("Too many vestings")
        );
        require(
            _start <= _cliff && _cliff <= _vested,
            WrongCliffDate("Wrong cliff date")
        );

        uint256 vestingId = vestingsLengths[_receiver]++;
        vestings[_receiver][vestingId] = TokenVesting(
            _amount,
            _start,
            _cliff,
            _vested,
            _revokable
        );

        emit NewVesting(_receiver, vestingId, _amount);

        return vestingId;
    }

    /**
     * @notice Revoke vesting #`_vestingId` from `_holder`, returning unvested tokens to the Token Manager
     * @param _holder Address whose vesting to revoke
     * @param _vestingId Numeric id of the vesting
     */

    function revokeVesting(
        address _holder,
        uint256 _vestingId
    ) external vestingExists(_holder, _vestingId) onlyOwner {
        TokenVesting storage v = vestings[_holder][_vestingId];
        require(v.revokable, VestingNotRevokable("Vesting not revokable"));

        uint256 nonVested = _calculateNonVestedTokens(
            v.amount,
            block.timestamp,
            v.start,
            v.cliff,
            v.vesting
        );

        delete vestings[_holder][_vestingId];

        require(
            transferFrom(_holder, address(this), nonVested),
            RevokeTransferFromReverted()
        );

        emit RevokeVesting(_holder, _vestingId, nonVested);
    }

    /**
     * @notice Burn `@tokenAmount(self.token(): address, _amount, false)` tokens from `_holder`
     * @param _holder Holder of tokens being burned
     * @param _amount Number of tokens being burned
     */
    function burn(address _holder, uint256 _amount) external onlyOwner {
        require(
            _transferableBalance(_holder, block.timestamp) >= _amount,
            NotEnoughUnlockedTokens()
        );
        _burn(_holder, _amount);
    }

    /* ======== VIEW ======== */

    function _calculateNonVestedTokens(
        uint256 tokens,
        uint256 time,
        uint256 start,
        uint256 cliff,
        uint256 vested
    ) private pure returns (uint256) {
        // Shortcuts for before cliff and after vested cases.
        if (time >= vested) {
            return 0;
        }
        if (time < cliff) {
            return tokens;
        }

        uint256 vestedTokens = (tokens * (time - start)) / (vested - start);

        return tokens - vestedTokens;
    }

    function _transferableBalance(
        address _holder,
        uint256 _time
    ) internal view returns (uint256) {
        uint256 transferable = balanceOf(_holder);

        // Contract does not have a spending limit on its own balance
        if (_holder != address(this)) {
            uint256 vestingsCount = vestingsLengths[_holder];
            for (uint256 i = 0; i < vestingsCount; i++) {
                TokenVesting storage v = vestings[_holder][i];
                uint256 nonTransferable = _calculateNonVestedTokens(
                    v.amount,
                    _time,
                    v.start,
                    v.cliff,
                    v.vesting
                );
                transferable = transferable - nonTransferable;
            }
        }

        return transferable;
    }

    // function onTransfer(
    //     address _from,
    //     uint256 _amount
    // ) external view returns (bool) {
    //     return _transferableBalance(_from, block.timestamp) >= _amount;
    // }

    /* ======== OVERRIDDEN METHODS ======== */

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(
            _transferableBalance(msg.sender, block.timestamp) >= amount,
            NotEnoughUnlockedTokens()
        );
        return super.transfer(recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(
            _transferableBalance(sender, block.timestamp) >= amount,
            NotEnoughUnlockedTokens()
        );
        return super.transferFrom(sender, recipient, amount);
    }
}
