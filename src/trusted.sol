pragma solidity ^0.4.23;


/**
 * @title TrustedAccounts
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Smart contract for each account to maintain a public list of trusted accounts.
 */
contract TrustedAccounts {

    /**
     * @dev Mapping of account to mapping of trusted to whether account trusts trusted.
     */
    mapping (address => mapping(address => bool)) accountTrustedAccount;

    /**
     * @dev Mapping of account to array of trusted accounts.
     */
    mapping (address => address[]) accountTrustedAccountList;

    /**
     * @dev An account now trusts another account.
     * @param account The trusting account.
     * @param trusted The account being trusted.
     */
    event TrustAccount(address account, address trusted);

    /**
     * @dev An account now does not trust another account.
     * @param account The trusting account.
     * @param trusted The account no longer being trusted.
     */
    event UntrustAccount(address account, address trusted);

    /**
     * @dev Revert if the account is not trusted by the sender.
     * @param account Account to be checked.
     */
    modifier isTrusted(address account) {
        require (accountTrustedAccount[msg.sender][account]);
        _;
    }

    /**
     * @dev Revert if the account is trusted by the sender.
     * @param account Account to be checked.
     */
    modifier isNotTrusted(address account) {
        require (!accountTrustedAccount[msg.sender][account]);
        _;
    }

    /**
     * @dev Record the sender as trusting an account.
     * @param account Account to be trusted.
     */
    function trustAccount(address account) external isNotTrusted(account) {
        // Record the sender as trusting this account.
        accountTrustedAccount[msg.sender][account] = true;
        // Add the account to the list of accounts the sender trusts.
        accountTrustedAccountList[msg.sender].push(account);
        // Log the trusting of the account.
        emit TrustAccount(msg.sender, account);
    }

    /**
     * @dev Remove of record of sender trusting an account.
     * @param account Account to not be trusted by sender.
     */
    function unTrustAccount(address account) external isTrusted(account) {
        // Record the sender as not trusting this account.
        delete accountTrustedAccount[msg.sender][account];
        // Find the account in the senders list of trusted accounts.
        address[] storage trustedList = accountTrustedAccountList[msg.sender];
        for (uint i = 0; i < trustedList.length; i++) {
            if (trustedList[i] == account) {
                // Overwrite the account to be removed with the last account.
                trustedList[i] = trustedList[--trustedList.length];
                break;
            }
        }
        // Log the untrusting of account.
        emit UntrustAccount(msg.sender, account);
    }

    /**
     * @dev Check if the sender trusts account.
     * @param account Account to check.
     */
    function getIsTrusted(address account) external view returns (bool) {
        return accountTrustedAccount[msg.sender][account];
    }

    /**
     * @dev Check if the sender trusts account.
     * @param account Trusting account.
     * @param trusted Trusted account.
     */
    function getIsTrustedByAccount(address account, address trusted) external view returns (bool) {
        return accountTrustedAccount[account][trusted];
    }

    /**
     * @dev Check if the sender trusts account.
     * @param account Account to check.
     */
    function getIsTrustedDeep(address account) external view returns (bool) {
        // Check if the sender trusts account.
        if (accountTrustedAccount[msg.sender][account]) {
            return true;
        }
        // Check all the accounts trusted by sender.
        address[] storage trustedList = accountTrustedAccountList[msg.sender];
        for (uint i = 0; i < trustedList.length; i++) {
            if (trustedList[i] == account) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Check if the sender trusts account.
     * @param account Trusting account.
     * @param trusted Trusted account.
     */
    function getIsTrustedDeepByAccount(address account, address trusted) external view returns (bool) {
        // Check if the sender trusts account.
        if (accountTrustedAccount[account][trusted]) {
            return true;
        }
        // Check all the accounts trusted by account.
        address[] storage trustedList = accountTrustedAccountList[msg.sender];
        for (uint i = 0; i < trustedList.length; i++) {
            if (trustedList[i] == trusted) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Get all accounts trusted by sender.
     * @return All accounts trusted by sender.
     */
    function getAllTrusted() external view returns (address[]) {
        return accountTrustedAccountList[msg.sender];
    }

    /**
     * @dev Get all accounts trusted by specific account.
     * @param account Account to check.
     * @return All accounts trusted by account.
     */
    function getAllTrustedByAccount(address account) external view returns (address[]) {
        return accountTrustedAccountList[account];
    }

}
