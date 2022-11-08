-- stocker NOM de l'image
-- L'index tile
-- size tile

local TextureComponent = require(_G.libDir .. "middleclass")("Texture")

TextureComponent.static.name = "Agility"
TextureComponent.static.client = false

function TextureComponent:initialize(name, index, size)
    self.index = 0
    self.name = agility or 0
    self.size = 16
end

return TextureComponent