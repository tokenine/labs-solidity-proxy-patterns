# Smart contract Troubleshooting


## Different kinds of Revert Transaction Messages


### 1) When Seller mint an NFT on the platform
```
msg value too low
```
`The minting fee (in unit of BNB) set by minter is lower than required by platform.`
```
token amount is too low
```
`The minting fee (in unit of quoted token) set by minter is lower than required by platform.`


### 2) When burning specific NFT
```
caller is not owner nor approved
```
`The one who call is niether the owner of the NFT nor being approved to spend the token.`

### 3) Access Controll error

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

### 3)  When Owner updates or sets  an NFT minting fee

```
No need to update
```

` The current mint fee `