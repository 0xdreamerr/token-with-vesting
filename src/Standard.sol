// SPDX-License-Identifier: MIT

// NOTE: Solidity version SHOULD be highest available version at the time of development

pragma solidity ^0.8.27;

/* ====== EXTERNAL IMPORTS ====== */

// NOTE: Adding new dependencies and changing remappings REQUIRES you to:
//       1. Execute `forge re` ("re" - alias for remapping)
//       2. Reload VSCode for Solidity extensions to pull new dependencies

/* ====== PREREQUISITES ====== */

// Comments, technical docs and other texts MUST use keywords in format and meaning described in RFC2119
// https://datatracker.ietf.org/doc/html/rfc2119
// This standard is used by Ethereum Improvement Proposals (EIP) writers and good devs

/// @title Standard
/// @author 0xRatWithRevolver and THE BOYS
/// @notice Standard for writing contracts
contract Standard {
    /* ======== STATE ======== */

    // NOTE: Values that are defined approximately (withdrawal limit, fee, etc.)
    //       SHOULD have setters (ownable)

    uint public number;

    // NOTE: Constants are only used for values that CAN'T be changed right before deployment

    uint public constant CONSTANT_NUMBER = 10;

    // NOTE: Name of key/value CAN be skipped if mapping name is self-explanatory
    //       for example balances mapping

    mapping(address keyName => uint valueName) public exampleMapping;

    /* ======== ERRORS ======== */

    // NOTE: ERRORS and EVENTS CAN be extracted to separate file (e.g. Errors.sol, Events.sol or interface)

    // NOTE: It's better to pass value to an error, than not

    error NumberTooHigh(uint number);

    /* ======== EVENTS ======== */

    event NumberSet(uint newNumber);

    // NOTE: bytes of arrays SHOULD be passed to event
    //       due to fact that EVM doesn't write full data, only hashes

    /* ======== CONSTRUCTOR AND INIT ======== */

    // NOTE: most values SHOULD be assigned via constructor to not mess up deployment process
    //       if value business requirements CAN change

    constructor() {}

    /* ======== EXTERNAL/PUBLIC ======== */

    // NOTE: Comments on functions and contracts MUST be written in NatSpec format
    //       https://docs.soliditylang.org/en/latest/natspec-format.html
    //       This allows to generate docs automatically

    /// @notice Set the number to a new value
    /// @dev Function SHOULD be restricted
    /// @param newNumber The new number to set
    function setNumber(uint newNumber) external {
        number = newNumber;
    }

    /// @notice Increment the number by 1
    /// @dev Function SHOULD be restricted
    /// @return The new number
    function increment() external returns (uint) {
        return ++number;
    }

    /* ======== INTERNAL ======== */

    /// @notice Increment the number by 1
    /// @dev Function SHOULD be restricted
    /// @return The new number
    function _decrement() internal returns (uint) {
        return --number;
    }

    /* ======== ADMIN ======== */

    /* ======== VIEW ======== */

    /// @notice Get the number
    /// @return The number
    function getNumber() external view returns (uint) {
        return number;
    }
}
