import FungibleToken from 0x05
import FlowToken from 0x05
import Gtoken from 0x05

transaction(senderAccount: Address, amount: UFix64) {

    // Define references
    let senderVault: &Gtoken.Vault{Gtoken.CollectionPublic}
    let signerVault: &Gtoken.Vault
    let senderFlowVault: &FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}
    let adminResource: &Gtoken.Admin
    let flowMinter: &FlowToken.Minter

    prepare(acct: AuthAccount) {
        // Borrow references and handle errors
        self.adminResource = acct.borrow<&Gtoken.Admin>(from: /storage/AdminStorage)
            ?? panic("Admin Resource is not present")

        self.signerVault = acct.borrow<&Gtoken.Vault>(from: /storage/VaultStorage)
            ?? panic("Vault not found in signerAccount")

        self.senderVault = getAccount(senderAccount)
            .getCapability(/public/Vault)
            .borrow<&Gtoken.Vault{Gtoken.CollectionPublic}>()
            ?? panic("Vault not found in senderAccount")

        self.senderFlowVault = getAccount(senderAccount)
            .getCapability(/public/FlowVault)
            .borrow<&FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider }>()
            ?? panic("Flow vault not found in senderAccount")

        self.flowMinter = acct.borrow<&FlowToken.Minter>(from: /storage/FlowMinter)
            ?? panic("Minter is not present")
    }

    execute {
        // Admin withdraws customtokens from sender's vault
        let newVault <- self.adminResource.adminGetCoin(senderVault: self.senderVault, amount: amount)
        log(newVault.balance)
        // Deposit withdrawn tokens to signer's vault
        self.signerVault.deposit(from: <-newVault)

        // Mint new FlowTokens
        let newFlowVault <- self.flowMinter.mintTokens(amount: amount)

        // Deposit new FlowTokens to sender's Flow vault
        self.senderFlowVault.deposit(from: <-newFlowVault)
        
        
        log("Done!!!")
    }
}