pragma solidity ^0.4.23;

import "ds-test/test.sol";

import "./trusted_accounts.sol";
import "./trusted_accounts_proxy.sol";


/**
 * @title TrustedAccountsTest
 * @author Jonathan Brown <jbrown@mix-blockchain.org>
 * @dev Testing contract for TrustedAccounts.
 */
contract TrustedAccountsTest is DSTest {

    TrustedAccounts trustedAccounts;
    TrustedAccountsProxy trustedAccountsProxy;

    function setUp() public {
        trustedAccounts = new TrustedAccounts();
        trustedAccountsProxy = new TrustedAccountsProxy(trustedAccounts);
    }

    function testControlCantTrustTrusted() public {
        trustedAccounts.trustAccount(0x1234);
        trustedAccounts.trustAccount(0x2345);
    }

    function testFailCantTrustTrusted() public {
        trustedAccounts.trustAccount(0x1234);
        trustedAccounts.trustAccount(0x1234);
    }

    function testTrustAccount() public {
        trustedAccounts.trustAccount(0x1234);
        assertEq(trustedAccounts.getTrustedCount(), 1);
        assertTrue(trustedAccounts.getIsTrusted(0x1234));
        trustedAccounts.trustAccount(0x2345);
        assertEq(trustedAccounts.getTrustedCount(), 2);
        assertTrue(trustedAccounts.getIsTrusted(0x2345));
        trustedAccounts.trustAccount(0x4567);
        assertEq(trustedAccounts.getTrustedCount(), 3);
        assertTrue(trustedAccounts.getIsTrusted(0x4567));
        trustedAccounts.trustAccount(0x5678);
        assertEq(trustedAccounts.getTrustedCount(), 4);
        assertTrue(trustedAccounts.getIsTrusted(0x5678));
    }

    function testControlCantUntrustUntrusted() public {
        trustedAccounts.trustAccount(0x1234);
        trustedAccounts.untrustAccount(0x1234);
    }

    function testFailCantUntrustUntrusted() public {
        trustedAccounts.untrustAccount(0x1234);
    }

    function testUntrustAccount() public {
        trustedAccounts.trustAccount(0x1234);
        trustedAccounts.trustAccount(0x2345);
        trustedAccounts.trustAccount(0x4567);
        trustedAccounts.trustAccount(0x5678);

        trustedAccounts.untrustAccount(0x2345);
        assertEq(trustedAccounts.getTrustedCount(), 3);
        assertTrue(trustedAccounts.getIsTrusted(0x1234));
        assertTrue(!trustedAccounts.getIsTrusted(0x2345));
        assertTrue(trustedAccounts.getIsTrusted(0x4567));
        assertTrue(trustedAccounts.getIsTrusted(0x5678));

        trustedAccounts.untrustAccount(0x5678);
        assertEq(trustedAccounts.getTrustedCount(), 2);
        assertTrue(trustedAccounts.getIsTrusted(0x1234));
        assertTrue(!trustedAccounts.getIsTrusted(0x2345));
        assertTrue(trustedAccounts.getIsTrusted(0x4567));
        assertTrue(!trustedAccounts.getIsTrusted(0x5678));

        trustedAccounts.untrustAccount(0x1234);
        assertEq(trustedAccounts.getTrustedCount(), 1);
        assertTrue(!trustedAccounts.getIsTrusted(0x1234));
        assertTrue(!trustedAccounts.getIsTrusted(0x2345));
        assertTrue(trustedAccounts.getIsTrusted(0x4567));
        assertTrue(!trustedAccounts.getIsTrusted(0x5678));

        trustedAccounts.untrustAccount(0x4567);
        assertEq(trustedAccounts.getTrustedCount(), 0);
        assertTrue(!trustedAccounts.getIsTrusted(0x1234));
        assertTrue(!trustedAccounts.getIsTrusted(0x2345));
        assertTrue(!trustedAccounts.getIsTrusted(0x4567));
        assertTrue(!trustedAccounts.getIsTrusted(0x5678));
    }

    function testGetIsTrustedByAccount() public {
        trustedAccountsProxy.trustAccount(0x1234);
        assertTrue(!trustedAccounts.getIsTrustedByAccount(msg.sender, 0x1234));
        assertTrue(trustedAccounts.getIsTrustedByAccount(trustedAccountsProxy, 0x1234));
    }

}
