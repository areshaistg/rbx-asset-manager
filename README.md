# rbx-asset-manager

Easily load unpublished animation clips during development, and alert on published games.

The default assets folder is `ReplicatedStorage/Assets`. This can be changed by setting the `ASSET_MANAGER_DIR` attribute in ReplicatedStorage.

# methods

## `GetAsset`
Get an instance from assets. Accepts a path separated by `/`s.

```luau
local AssetManager = require(Packages.AssetManager)

local foo = AssetManager:GetAsset("Models/Foo") :: Model
```

## `GetAnimation`
Get an animation from assets. Accepts a path separated by `/`s. Will return an `Animation` with a temporary id if an `AnimationClip` was found.

```luau
local AssetManager = require(Packages.AssetManager)

local run = AssetManager:GetAsset("Animations/Locomotion/Run")
```

## `Curry`
Quality-of-life method for shorter path strings. Will return another AssetManager instance with the same cache as the top-most instance.

```luau
local AssetManager = require(Packages.AssetManager)

-- We are working with a smaller subset of assets, all included in `Weapons/LongSword`
local model = AssetManager:GetAsset("Weapons/LongSword/SwordModel")
local stab1 = AssetManager:GetAsset("Weapons/LongSword/Animations/Stab1")
local slash = AssetManager:GetAsset("Weapons/LongSword/Effects/Slash")

-- Using Curry
local assets = AssetManager:GetAsset("Weapons/LongSword")

local model = assets:GetAsset("SwordModel")
local stab1 = assets:GetAsset("Animations/Stab1")
local slash = assets:GetAsset("Effects/Slash")
```
