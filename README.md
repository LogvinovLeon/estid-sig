## Ethstonia

Identity and KYC/AML are the biggest problems in Blockchain right now. The Estonian government issues an eResidency card to all humans. This card has a private key build in for signing stuff (in a legally binding manner).

Can we sign Ethereum transactions with it? After today, YES!

The best part: It is completely trustless! There is no server. Just a static page. All verification happens on-chain. It can become a simple library that can be integrated in DApps and Wallets. The root of trust is the Estonian government.

When you loose your card, you can get a new one at the Esonian embassy. The wallet contract automatically accepts your new card, since the wallet is tied to your citizen id, and the certificate is signed by the Estonian government. The root of trust is the CA root key of the Estonian government.

## What it does

It is a wallet contract that is controlled by your Estonia issued Identity card and tied to your citizen number.

## How we built it

* Reverse engineer the Estonian e-Identity signature mechanism.

* Implement all the crypto in Python using libraries.
* Implement all the crypto in Python from scratch.

* Implement some 384-bit bignumber utilities in Solidity and EVM Assembly.
* Implement the Secp384r1 384-bit finite field in Solidity and EVM Assembly.
* Implement the Secp384r1 generator order finite field in Solidity and EVM Assembly.
* Implement the Secp384r1 elliptic curve in Solidity.
* Implement the ECDSA signature verification scheme in Solidity.
* Add a ton of tests
* Fix a ton of bugs
* Optimize, optimize, optimize

* Implement a wallet contract using e-Identity signatures.
* Implement a rudimentary front end for the wallet.

## Challenges we ran into

We expected the cards to used RSA2048 signatures as documented. Instead we found that they use 384 bit elliptic curves. RSA is easy to implement thanks to EIP198. Elliptic curves are a *lot* more complex. It is especially hard since 384-bit math does not fit in the EVMs 256-bit words.

Gas cost is an issue. When we first got it working, a signature verification took half a billion gas. After some precomputations and optimizations we got it down to 20 million. We have two more tricks (Jacobi coordinates and base 4 precomputes) that we did not get to implement. With these included gas cost will be below the block gas limit, making the wallet viable on main net. There is likely room for further tuning.

## Accomplishments that we're proud of

As far as we know, we are the first in the world to transact on the blockchain using a government issued ID. We are the first to sign transactions with a recognized, legally binding signature.

We build it all in a little over one day.

## What we learned

* Estonia loves blockchain. They will likely support our project.
* They switched from RSA2048 to Secp384r1 and did not update their documentation!
* Vitalik's trick to use EIP198 for multiplication is much slower than our chinese remainder based one.
* The eResidency signature scheme could learn a thing or two from EIP712. There is currently no domain separation.

## What's next for Ethstonia Identity

* Build a better UX
* Allow anyone to create a wallet with their cards.
* Key updates using certificates and the Estonian government pubkey.

### TODO

* Implement Jacobi elliptic curve coordinates.
* Use base 4 or more instead of base 2 for the lookup table.
* Spread lookup table generation in multiple TXs.
* Implement certificate parsing to extract citizen number, public key and signature.
* Implement RSA (easier).
* Pin Estonian government root key.
* Verify public keys back 
* Implement key revocation lists.
