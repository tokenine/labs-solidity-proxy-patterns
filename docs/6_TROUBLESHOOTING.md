# Smart contract Troubleshooting


## Different kinds of Revert Transaction Messages


### Artwork Smart contract


#### 1) When Seller mint an NFT on the platform
```
msg value too low
```
`The minting fee (in unit of BNB) set by minter is lower than required by platform.`
```
token amount is too low
```
`The minting fee (in unit of quoted token) set by minter is lower than required by platform.`


#### 2) When burning specific NFT
```
caller is not owner nor approved
```
`The one who call is niether the owner of the NFT nor being approved to spend the token.`

#### 3) Access Controll error

```
Must have update token uri role
```
and 
```
Must have pause role
```

` The caller has not been grant the relevant role` 

```
FORBIDDEN
```
` The caller must be mintFeeAddr `

#### 3)  When Owner updates or sets either  NFT minting fee or fee address

```
No need to update
```

` The fee being updated has the same value as the current mint fee `

#### 4)  When querying non-exist NFT


```
ERC721Metadata: URI query for nonexistent token
```

```
ERC721Metadata: URI set of nonexistent token
```

` The NFT does not exist `



### BidNft Smart contract

#### 1) When seller sets the current price of NFT to sell

```
Only Seller can update price
```
`The caller is not seller`

```
Price must be greater than zero
```

`Price can not go negative`


#### 2) When seller sets the end time of NFT selling period

```
Only Seller can set endtime
```

`The caller is not seller`


```
Endtime must be granter than current time
```
`End time must be in the future.`

#### 3) When seller offers ask prices of NFT

```
Only Token Owner can sell token
```

`Token who owns the NFTs is the one who can sell them.`


#### 4) When user buys token

```
Wrong msg sender
```

`Caller whose addressed must not be zero and is AetworkNft address`

```
Token not in sell book
```
`can not buy NFTs which are not being offered to sell by owner.`

```
You must cancel your bid first
```

`User must cancel the remaining bids of the same NFT before buy it`

```
The end time have passed
```
`End time must be in the future.`

#### 5) When user sells token

```
Token not in sell book"
```

`can not buy NFTs which are not being offered to sell by owner.`

```
Only owner can sell token
```

`Token who owns the NFTs is the one who can sell them.`

```
Bidder does not exist
```

`There is no bid of relevant NFT yet`

#### 6) When owner removes supported tokens as curreny

```
not found
```

`The token being requested is not in the support list in the first place`

#### 7) When owner change percent fee

```
No need to update
```

` The fee being updated has the same value as the current fee `
