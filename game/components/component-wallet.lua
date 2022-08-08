local WalletComponent = require(_G.libDir .. "middleclass")("Wallet")

WalletComponent.static.name = "Wallet"
WalletComponent.static.client = true

function WalletComponent:initialize(wallet)
    self.wallet = wallet or 0
end

return WalletComponent