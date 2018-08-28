pragma solidity ^0.4.24;


/**
 * @title TrustedAccounts
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Smart contract for each account to maintain a public list of trusted accounts.
 */
contract TrustedAccounts {

    /**
     * @dev Mapping of account1 to mapping of account2 to whether account1 trusts account2.
     */
    mapping (address => mapping(address => bool)) accountTrustedAccount;

    /**
     * @dev Mapping of account to array of trusted accounts.
     */
    mapping (address => address[]) accountTrustedAccountList;

    /**
     * @dev An account now trusts another account.
     * @param account Account that now trusts another account.
     * @param trusted Account being trusted.
     */
    event TrustAccount(address indexed account, address indexed trusted);

    /**
     * @dev An account now does not trust another account.
     * @param account Account that no longer trusts another account.
     * @param untrusted Account no longer being trusted.
     */
    event UntrustAccount(address indexed account, address indexed untrusted);

    /**
     * @dev Revert if the account is not trusted by the sender.
     * @param account Account that must be trusted.
     */
    modifier isTrusted(address account) {
        require (accountTrustedAccount[msg.sender][account]);
        _;
    }

    /**
     * @dev Revert if the account is the sender.
     * @param account Account that must not be the sender.
     */
    modifier isNotSender(address account) {
        require (account != msg.sender);
        _;
    }

    /**
     * @dev Revert if the account is trusted by the sender.
     * @param account Account that must not be trusted.
     */
    modifier isNotTrusted(address account) {
        require (!accountTrustedAccount[msg.sender][account]);
        _;
    }

    /**
     * @dev Record the sender as trusting an account.
     * @param account Account to be trusted by sender.
     */
    function trustAccount(address account) external isNotSender(account) isNotTrusted(account) {
        // Record the sender as trusting this account.
        accountTrustedAccount[msg.sender][account] = true;
        // Add the account to the list of accounts the sender trusts.
        accountTrustedAccountList[msg.sender].push(account);
        // Log the trusting of the account.
        emit TrustAccount(msg.sender, account);
    }

    /**
     * @dev Unrecord the sender as trusting an account.
     * @param account Account to not be trusted by sender.
     */
    function untrustAccount(address account) external isTrusted(account) {
        // Record the sender as not trusting this account.
        delete accountTrustedAccount[msg.sender][account];
        // Find the account in the senders list of trusted accounts.
        address[] storage trustedList = accountTrustedAccountList[msg.sender];
        for (uint i = 0; i < trustedList.length; i++) {
            if (trustedList[i] == account) {
                // Check if this is not the last account.
                if (i != trustedList.length - 1) {
                  // Overwrite the account with the last account.
                  trustedList[i] = trustedList[trustedList.length - 1];
                }
                // Remove the last account.
                trustedList.length--;
                break;
            }
        }
        // Log the untrusting of account.
        emit UntrustAccount(msg.sender, account);
    }

    /**
     * @dev Check if an account trusts another account.
     * @param account Account to be checked if it trusts another account.
     * @param accountToCheck Account to be checked if it is trusted.
     */
    function getIsTrustedByAccount(address account, address accountToCheck) public view returns (bool) {
        return accountTrustedAccount[account][accountToCheck];
    }

    /**
     * @dev Check if the sender trusts an account.
     * @param accountToCheck Account to be checked if it is trusted.
     */
    function getIsTrusted(address accountToCheck) external view returns (bool) {
        return accountTrustedAccount[msg.sender][accountToCheck];
    }

    /**
     * @dev Check if an account trusts multiple accounts.
     * @param account Account to be checked if it trusts multiple accounts.
     * @param accountsToCheck Accounts to be checked if they are trusted.
     */
    function getIsTrustedByAccountMultiple(address account, address[] accountsToCheck) public view returns (bool[] results) {
        results = new bool[](accountsToCheck.length);
        for (uint i = 0; i < accountsToCheck.length; i++) {
            results[i] = accountTrustedAccount[account][accountsToCheck[i]];
        }
    }

    /**
     * @dev Check if the sender trusts multiple accounts.
     * @param accountsToCheck Accounts to be checked if they are trusted.
     */
    function getIsTrustedMultiple(address[] accountsToCheck) external view returns (bool[] results) {
        results = getIsTrustedByAccountMultiple(msg.sender, accountsToCheck);
    }

    /**
     * @dev Check only deep if the sender trusts an account.
     * @param account Account to be checked if it trusts an account.
     * @param accountToCheck Account to be checked if it is trusted.
     */
    function getIsTrustedOnlyDeepByAccount(address account, address accountToCheck) public view returns (bool) {
        // Check all the accounts trusted by account.
        address[] storage trustedList = accountTrustedAccountList[account];
        for (uint i = 0; i < trustedList.length; i++) {
            if (accountTrustedAccount[trustedList[i]][accountToCheck]) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Check only deep if the sender trusts an account.
     * @param accountToCheck Account to be checked if it is trusted.
     */
    function getIsTrustedOnlyDeep(address accountToCheck) external view returns (bool) {
        return getIsTrustedOnlyDeepByAccount(msg.sender, accountToCheck);
    }

    /**
     * @dev Check only deep if the sender trusts multiple accounts.
     * @param account Account to be checked if it trusts multiple accounts.
     * @param accountsToCheck Accounts to be checked if they are trusted.
     */
    function getIsTrustedOnlyDeepByAccountMultiple(address account, address[] accountsToCheck) public view returns (bool[] results) {
        results = new bool[](accountsToCheck.length);
        for (uint i = 0; i < accountsToCheck.length; i++) {
            results[i] = getIsTrustedOnlyDeepByAccount(account, accountsToCheck[i]);
        }
    }

    /**
     * @dev Check only deep if the sender trusts multiple accounts.
     * @param accountsToCheck Accounts to be checked if they are trusted.
     */
    function getIsTrustedOnlyDeepMultiple(address[] accountsToCheck) external view returns (bool[] results) {
        results = getIsTrustedOnlyDeepByAccountMultiple(msg.sender, accountsToCheck);
    }

    /**
     * @dev Check deep if an account trusts another account.
     * @param account Account to be checked if it trusts another account.
     * @param accountToCheck Account to be checked if it is trusted.
     */
    function getIsTrustedDeepByAccount(address account, address accountToCheck) public view returns (bool) {
        // Check if the sender trusts account.
        if (accountTrustedAccount[account][accountToCheck]) {
            return true;
        }
        return getIsTrustedOnlyDeepByAccount(account, accountToCheck);
    }

    /**
     * @dev Check deep if the sender trusts an account.
     * @param accountToCheck Account to be checked if it is trusted.
     */
    function getIsTrustedDeep(address accountToCheck) external view returns (bool) {
        return getIsTrustedDeepByAccount(msg.sender, accountToCheck);
    }

    /**
     * @dev Check deep if the sender trusts multiple accounts.
     * @param account Account to be checked if it trusts multiple accounts.
     * @param accountsToCheck Accounts to be checked if they are trusted.
     */
    function getIsTrustedDeepByAccountMultiple(address account, address[] accountsToCheck) public view returns (bool[] results) {
        results = new bool[](accountsToCheck.length);
        for (uint i = 0; i < accountsToCheck.length; i++) {
            results[i] = getIsTrustedDeepByAccount(account, accountsToCheck[i]);
        }
    }

    /**
     * @dev Check deep if the sender trusts multiple accounts.
     * @param accountsToCheck Accounts to be checked if they are trusted.
     */
    function getIsTrustedDeepMultiple(address[] accountsToCheck) external view returns (bool[] results) {
        results = getIsTrustedDeepByAccountMultiple(msg.sender, accountsToCheck);
    }

    /**
     * @dev Get number of accounts trusted by sender.
     * @return Number of accounts trusted by sender.
     */
    function getTrustedCount() external view returns (uint) {
        return accountTrustedAccountList[msg.sender].length;
    }

    /**
     * @dev Get all accounts trusted by sender.
     * @return All accounts trusted by sender.
     */
    function getAllTrusted() external view returns (address[]) {
        return accountTrustedAccountList[msg.sender];
    }

    /**
     * @dev Get number of accounts trusted by account.
     * @return Number of accounts trusted by account.
     */
    function getTrustedCountByAccount(address account) external view returns (uint) {
        return accountTrustedAccountList[account].length;
    }

    /**
     * @dev Get all accounts trusted by account.
     * @param account Account to get accounts it trusts.
     * @return All accounts trusted by account.
     */
    function getAllTrustedByAccount(address account) external view returns (address[]) {
        return accountTrustedAccountList[account];
    }

    /**
     * @dev Get a list of trusted accounts that trust an account.
     * @param account Account to be checked who it trusts that trusts accountToCheck.
     * @param accountToCheck Account to check who trusts it.
     * @return List of accounts that are trusted by account and trust accountToCheck.
     */
    function getTrustedThatTrustAccountByAccount(address account, address accountToCheck) public view returns (address[] results) {
        uint trustedCount = accountTrustedAccountList[account].length;
        bool[] memory trustedTrust = new bool[](trustedCount);
        uint trustedTrustCount = 0;
        // Check which accounts that account trusts trust accountToCheck.
        for (uint i = 0; i < trustedCount; i++) {
            if (getIsTrustedByAccount(accountTrustedAccountList[account][i], accountToCheck)) {
                trustedTrust[i] = true;
                trustedTrustCount++;
            }
            else {
                trustedTrust[i] = false;
            }
        }
        // Store the results.
        results = new address[](trustedTrustCount);
        uint j = 0;
        for (i = 0; i < trustedCount; i++) {
            if (trustedTrust[i]) {
                results[j++] = accountTrustedAccountList[account][i];
            }
        }
    }

    /**
     * @dev Get a list of trusted accounts that trust an account.
     * @param accountToCheck Account to check who trusts it.
     * @return List of accounts that are trusted by sender and trust accountToCheck.
     */
    function getTrustedThatTrustAccount(address accountToCheck) external view returns (address[] results) {
        results = getTrustedThatTrustAccountByAccount(msg.sender, accountToCheck);
    }

}
