pragma solidity ^0.5.7;

import "ds-test/test.sol";

import "./TrustedAccounts.sol";
import "./TrustedAccountsProxy.sol";


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
        trustedAccounts.trustAccount(address(0x1234));
    }

    function testFailCantTrustSelf() public {
        trustedAccounts.trustAccount(address(this));
    }

    function testControlCantTrustTrusted() public {
        trustedAccounts.trustAccount(address(0x1234));
        trustedAccounts.trustAccount(address(0x2345));
    }

    function testFailCantTrustTrusted() public {
        trustedAccounts.trustAccount(address(0x1234));
        trustedAccounts.trustAccount(address(0x1234));
    }

    function testTrustAccount() public {
        trustedAccounts.trustAccount(address(0x1234));
        assertEq(trustedAccounts.getTrustedCount(), 1);
        assertTrue(trustedAccounts.getIsTrusted(address(0x1234)));
        trustedAccounts.trustAccount(address(0x2345));
        assertEq(trustedAccounts.getTrustedCount(), 2);
        assertTrue(trustedAccounts.getIsTrusted(address(0x2345)));
        trustedAccounts.trustAccount(address(0x4567));
        assertEq(trustedAccounts.getTrustedCount(), 3);
        assertTrue(trustedAccounts.getIsTrusted(address(0x4567)));
        trustedAccounts.trustAccount(address(0x5678));
        assertEq(trustedAccounts.getTrustedCount(), 4);
        assertTrue(trustedAccounts.getIsTrusted(address(0x5678)));
    }

    function testControlCantUntrustUntrusted() public {
        trustedAccounts.trustAccount(address(0x1234));
        trustedAccounts.untrustAccount(address(0x1234));
    }

    function testFailCantUntrustUntrusted() public {
        trustedAccounts.untrustAccount(address(0x1234));
    }

    function testUntrustAccount() public {
        trustedAccounts.trustAccount(address(0x1234));
        trustedAccounts.trustAccount(address(0x2345));
        trustedAccounts.trustAccount(address(0x4567));
        trustedAccounts.trustAccount(address(0x5678));

        trustedAccounts.untrustAccount(address(0x2345));
        assertEq(trustedAccounts.getTrustedCount(), 3);
        assertTrue(trustedAccounts.getIsTrusted(address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x2345)));
        assertTrue(trustedAccounts.getIsTrusted(address(0x4567)));
        assertTrue(trustedAccounts.getIsTrusted(address(0x5678)));

        trustedAccounts.untrustAccount(address(0x5678));
        assertEq(trustedAccounts.getTrustedCount(), 2);
        assertTrue(trustedAccounts.getIsTrusted(address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x2345)));
        assertTrue(trustedAccounts.getIsTrusted(address(0x4567)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x5678)));

        trustedAccounts.untrustAccount(address(0x1234));
        assertEq(trustedAccounts.getTrustedCount(), 1);
        assertTrue(!trustedAccounts.getIsTrusted(address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x2345)));
        assertTrue(trustedAccounts.getIsTrusted(address(0x4567)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x5678)));

        trustedAccounts.untrustAccount(address(0x4567));
        assertEq(trustedAccounts.getTrustedCount(), 0);
        assertTrue(!trustedAccounts.getIsTrusted(address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x4567)));
        assertTrue(!trustedAccounts.getIsTrusted(address(0x5678)));
    }

    function testGetIsTrustedByAccount() public {
        trustedAccountsProxy.trustAccount(address(0x1234));
        assertTrue(!trustedAccounts.getIsTrustedByAccount(msg.sender, address(0x1234)));
        assertTrue(trustedAccounts.getIsTrustedByAccount(address(trustedAccountsProxy), address(0x1234)));
    }

    function testGetIsTrustedDeep() public {
        trustedAccounts.trustAccount(address(0x1234));
        trustedAccounts.trustAccount(address(0x2345));
        trustedAccountsProxy.trustAccount(address(0x3456));
        trustedAccountsProxy.trustAccount(address(0x4567));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x1234)));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedDeep(address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedDeep(address(0x4567)));

        trustedAccounts.trustAccount(address(trustedAccountsProxy));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x1234)));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x2345)));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x3456)));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x4567)));

        trustedAccounts.untrustAccount(address(trustedAccountsProxy));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x1234)));
        assertTrue(trustedAccounts.getIsTrustedDeep(address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedDeep(address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedDeep(address(0x4567)));
    }

    function testGetIsTrustedDeepByAccount() public {
        trustedAccountsProxy2.trustAccount(address(0x1234));
        trustedAccountsProxy2.trustAccount(address(0x2345));
        trustedAccountsProxy.trustAccount(address(0x3456));
        trustedAccountsProxy.trustAccount(address(0x4567));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x1234)));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x4567)));

        trustedAccountsProxy2.trustAccount(address(trustedAccountsProxy));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x1234)));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x2345)));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x3456)));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x4567)));

        trustedAccountsProxy2.untrustAccount(address(trustedAccountsProxy));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x1234)));
        assertTrue(trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedDeepByAccount(address(trustedAccountsProxy2), address(0x4567)));
    }

    function testGetIsTrustedOnlyDeep() public {
        trustedAccounts.trustAccount(address(0x1234));
        trustedAccounts.trustAccount(address(0x2345));
        trustedAccountsProxy.trustAccount(address(0x3456));
        trustedAccountsProxy.trustAccount(address(0x4567));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x4567)));

        trustedAccounts.trustAccount(address(trustedAccountsProxy));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x2345)));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeep(address(0x3456)));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeep(address(0x4567)));

        trustedAccounts.untrustAccount(address(trustedAccountsProxy));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeep(address(0x4567)));
    }

    function testGetIsTrustedOnlyDeepByAccount() public {
        trustedAccountsProxy2.trustAccount(address(0x1234));
        trustedAccountsProxy2.trustAccount(address(0x2345));
        trustedAccountsProxy.trustAccount(address(0x3456));
        trustedAccountsProxy.trustAccount(address(0x4567));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x4567)));

        trustedAccountsProxy2.trustAccount(address(trustedAccountsProxy));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x2345)));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x3456)));
        assertTrue(trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x4567)));

        trustedAccountsProxy2.untrustAccount(address(trustedAccountsProxy));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x1234)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x2345)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x3456)));
        assertTrue(!trustedAccounts.getIsTrustedOnlyDeepByAccount(address(trustedAccountsProxy2), address(0x4567)));
    }

}
