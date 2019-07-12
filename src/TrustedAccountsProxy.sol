pragma solidity ^0.5.10;

import "./TrustedAccounts.sol";


/**
 * @title TrustedAccountsProxy
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Proxy contract for accessing a TrustedAccounts contract from a different address for testing purposes.
 */
contract TrustedAccountsProxy {

    TrustedAccounts trustedAccounts;

    /**
     * @param _trustedAccounts Real TrustedAccounts contract to proxy to.
     */
    constructor (TrustedAccounts _trustedAccounts) public {
        trustedAccounts = _trustedAccounts;
    }

    function trustAccount(address account) external {
        trustedAccounts.trustAccount(account);
    }

    function untrustAccount(address account) external {
        trustedAccounts.untrustAccount(account);
    }

    function getIsTrustedByAccount(address account, address accountToCheck) external view returns (bool) {
        return trustedAccounts.getIsTrustedByAccount(account, accountToCheck);
    }

    function getIsTrusted(address accountToCheck) external view returns (bool) {
        return trustedAccounts.getIsTrusted(accountToCheck);
    }

    function getIsTrustedByAccountMultiple(address account, address[] memory accountsToCheck) public view returns (bool[] memory results) {
        results = trustedAccounts.getIsTrustedByAccountMultiple(account, accountsToCheck);
    }

    function getIsTrustedMultiple(address[] calldata accountsToCheck) external view returns (bool[] memory results) {
        results = trustedAccounts.getIsTrustedMultiple(accountsToCheck);
    }

    function getIsTrustedOnlyDeepByAccount(address account, address accountToCheck) public view returns (bool) {
        return trustedAccounts.getIsTrustedOnlyDeepByAccount(account, accountToCheck);
    }

    function getIsTrustedOnlyDeep(address accountToCheck) external view returns (bool) {
        return trustedAccounts.getIsTrustedOnlyDeep(accountToCheck);
    }

    function getIsTrustedOnlyDeepByAccountMultiple(address account, address[] memory accountsToCheck) public view returns (bool[] memory results) {
        results = trustedAccounts.getIsTrustedOnlyDeepByAccountMultiple(account, accountsToCheck);
    }

    function getIsTrustedOnlyDeepMultiple(address[] calldata accountsToCheck) external view returns (bool[] memory results) {
        results = trustedAccounts.getIsTrustedOnlyDeepMultiple(accountsToCheck);
    }

    function getIsTrustedDeepByAccount(address account, address accountToCheck) public view returns (bool) {
        return trustedAccounts.getIsTrustedDeepByAccount(account, accountToCheck);
    }

    function getIsTrustedDeep(address accountToCheck) external view returns (bool) {
        return trustedAccounts.getIsTrustedDeep(accountToCheck);
    }

    function getIsTrustedDeepByAccountMultiple(address account, address[] memory accountsToCheck) public view returns (bool[] memory results) {
        results = trustedAccounts.getIsTrustedDeepByAccountMultiple(account, accountsToCheck);
    }

    function getIsTrustedDeepMultiple(address[] calldata accountsToCheck) external view returns (bool[] memory results) {
        results = trustedAccounts.getIsTrustedDeepMultiple(accountsToCheck);
    }

    function getTrustedCount() external view returns (uint) {
        return trustedAccounts.getTrustedCount();
    }

    function getAllTrusted() external view returns (address[] memory) {
        return trustedAccounts.getAllTrusted();
    }

    function getTrustedCountByAccount(address account) external view returns (uint) {
        return trustedAccounts.getTrustedCountByAccount(account);
    }

    function getAllTrustedByAccount(address account) external view returns (address[] memory) {
        return trustedAccounts.getAllTrustedByAccount(account);
    }

}