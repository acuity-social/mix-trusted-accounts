pragma solidity ^0.4.24;

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
    TrustedAccountsProxy trustedAccountsProxy2;

    function setUp() public {
        trustedAccounts = new TrustedAccounts();
        trustedAccountsProxy = new TrustedAccountsProxy(trustedAccounts);
        trustedAccountsProxy2 = new TrustedAccountsProxy(trustedAccounts);
    }

    function testControlCantTrustSelf() public {
        trustedAccounts.trustAccount(0x1234);
    }

    function testFailCantTrustSelf() public {
        trustedAccounts.trustAccount(this);
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

    function testGetIsTrustedDeep() public {
        trustedAccounts.trustAccount(0x1234);
        trustedAccounts.trustAccount(0x2345);
        trustedAccountsProxy.trustAccount(0x3456);
        trustedAccountsProxy.trustAccount(0x4567);
        assertTrue(trustedAccounts.getIsTrustedDeep(0x1234));
        assertTrue(trustedAccounts.getIsTrustedDeep(0x2345));
        assertTrue(!trustedAccounts.getIsTrustedDeep(0x3456));
        assertTrue(!trustedAccounts.getIsTrustedDeep(0x4567));

        trustedAccounts.trustAccount(trustedAccountsProxy);
        assertTrue(trustedAccounts.getIsTrustedDeep(0x1234));
        assertTrue(trustedAccounts.getIsTrustedDeep(0x2345));
        assertTrue(trustedAccounts.getIsTrustedDeep(0x3456));
        assertTrue(trustedAccounts.getIsTrustedDeep(0x4567));

        trustedAccounts.untrustAccount(trustedAccountsProxy);
        assertTrue(trustedAccounts.getIsTrustedDeep(0x1234));
        assertTrue(trustedAccounts.getIsTrustedDeep(0x2345));
        assertTrue(!trustedAccounts.getIsTrustedDeep(0x3456));
        assertTrue(!trustedAccounts.getIsTrustedDeep(0x4567));
    }

    function testGetIsTrustedDeepByAccount() public {
        trustedAccountsProxy2.trustAccount(0x1234);
        trustedAccountsProxy2.trustAccount(0x2345);
        trustedAccountsProxy.trustAccount(0x3456);
        trustedAccountsProxy.trustAccount(0x4567);
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x1234));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x2345));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x3456));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x4567));

        trustedAccountsProxy2.trustAccount(trustedAccountsProxy);
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x1234));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x2345));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x3456));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x4567));

        trustedAccountsProxy2.untrustAccount(trustedAccountsProxy);
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x1234));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x2345));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x3456));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(trustedAccountsProxy2, 0x4567));
    }

    function testGetIsTrustedOnlyDeep() public {
        trustedAccounts.trustAccount(0x1234);
        trustedAccounts.trustAccount(0x2345);
        trustedAccountsProxy.trustAccount(0x3456);
        trustedAccountsProxy.trustAccount(0x4567);
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x1234));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x2345));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x3456));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x4567));

        trustedAccounts.trustAccount(trustedAccountsProxy);
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x1234));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x2345));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeep(0x3456));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeep(0x4567));

        trustedAccounts.untrustAccount(trustedAccountsProxy);
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x1234));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x2345));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x3456));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(0x4567));
    }

    function testGetIsTrustedOnlyDeepByAccount() public {
        trustedAccountsProxy2.trustAccount(0x1234);
        trustedAccountsProxy2.trustAccount(0x2345);
        trustedAccountsProxy.trustAccount(0x3456);
        trustedAccountsProxy.trustAccount(0x4567);
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x1234));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x2345));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x3456));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x4567));

        trustedAccountsProxy2.trustAccount(trustedAccountsProxy);
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x1234));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x2345));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x3456));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x4567));

        trustedAccountsProxy2.untrustAccount(trustedAccountsProxy);
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x1234));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x2345));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x3456));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(trustedAccountsProxy2, 0x4567));
    }

}
