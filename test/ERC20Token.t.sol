// SPDX-License-Identifier: MIT
/// @notice This code demos how to test permit signatures and offchain signing. Signature
/// replays and stuff
pragma solidity ^0.8.20;

import "@openzeppelin-contracts/access/Ownable.sol";
import {IERC20Errors} from "@openzeppelin-contracts/interfaces/draft-IERC6093.sol";
import "@openzeppelin-contracts/token/ERC20/ERC20.sol";
import "@openzeppelin-contracts/token/ERC20/extensions/ERC20Permit.sol";
import {MessageHashUtils} from "@openzeppelin-contracts/utils/cryptography/MessageHashUtils.sol";
import {Test, console} from "forge-std/Test.sol";

contract MyToken is ERC20, Ownable, ERC20Permit {

    constructor(address initialOwner) ERC20("MyToken", "MTK") Ownable(initialOwner) ERC20Permit("MyToken") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

}

contract MyTokenTest is Test {

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    MyToken internal token;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);
        vm.label(owner, "owner");
        vm.label(spender, "spender");

        token = new MyToken(owner);

        vm.prank(owner);
        token.mint(owner, 1e18);
    }

    function test_Permit() public {
        Permit memory _permit = Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        // bytes32 digest = sigUtils.getTypedDataHash(permit);
        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);

        assertEq(token.allowance(owner, spender), 1e18);
        assertEq(token.nonces(owner), 1);
    }

    function testRevert_ExpiredPermit() public {
        Permit memory _permit =
            Permit({owner: owner, spender: spender, value: 1e18, nonce: token.nonces(owner), deadline: 1 days});

        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.warp(1 days + 1 seconds); // fast forward one second past the deadline

        vm.expectRevert(abi.encodeWithSelector(ERC20Permit.ERC2612ExpiredSignature.selector, 1 days));
        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);
    }

    function testRevert_InvalidSigner() public {
        Permit memory _permit =
            Permit({owner: owner, spender: spender, value: 1e18, nonce: token.nonces(owner), deadline: 1 days});

        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spenderPrivateKey, digest); // spender
        // signs owner's approval

        vm.expectRevert(
            abi.encodeWithSelector(ERC20Permit.ERC2612InvalidSigner.selector, _permit.spender, _permit.owner)
        );
        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);
    }

    function testRevert_SignatureReplay() public {
        Permit memory _permit = Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);

        vm.expectRevert();
        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);
    }

    function test_TransferFromLimitedPermit() public {
        Permit memory _permit = Permit({owner: owner, spender: spender, value: 1e18, nonce: 0, deadline: 1 days});

        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), 0);
    }

    function test_TransferFromMaxPermit() public {
        Permit memory _permit =
            Permit({owner: owner, spender: spender, value: type(uint256).max, nonce: 0, deadline: 1 days});

        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), type(uint256).max);
    }

    function test_Revert_InvalidAllowance() public {
        Permit memory _permit = Permit({
            owner: owner,
            spender: spender,
            value: 5e17, // approve only 0.5 tokens
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);

        vm.prank(spender);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, spender, 5e17, 1e18));
        token.transferFrom(owner, spender, 1e18); // attempt to transfer 1 token
    }

    function test_Revert_InvalidBalance() public {
        Permit memory _permit = Permit({
            owner: owner,
            spender: spender,
            value: 2e18, // approve 2 tokens
            nonce: 0,
            deadline: 1 days
        });

        bytes32 digest = MessageHashUtils.toTypedDataHash(
            token.DOMAIN_SEPARATOR(),
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, _permit.owner, _permit.spender, _permit.value, _permit.nonce, _permit.deadline
                )
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(_permit.owner, _permit.spender, _permit.value, _permit.deadline, v, r, s);

        vm.prank(spender);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, owner, 1e18, 2e18));
        token.transferFrom(owner, spender, 2e18); // attempt to transfer 2 tokens (owner
        // only owns 1)
    }

}
