import FungibleToken from 0x05
import Gtoken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &Gtoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Gtoken.CollectionPublic}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&Gtoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Gtoken.CollectionPublic}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- Gtoken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&Gtoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Gtoken.CollectionPublic}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &Gtoken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&Gtoken.Vault{FungibleToken.Balance}>()
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &Gtoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Gtoken.CollectionPublic} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&Gtoken.Vault{FungibleToken.Balance, FungibleToken.Receiver, Gtoken.CollectionPublic}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if Gtoken.vaults.contains(checkVault.uuid) {
            log(publicVault?.balance)
            log("This is a Atoken vault")
        } else {
            log("This is not a Atoken vault")
        }
    }
}