--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AnimationClipProvider = game:GetService("AnimationClipProvider")

local AssetManager = {}
AssetManager.__index = AssetManager

type self = {
    host: Instance,
    animation_clips: {[AnimationClip]: Animation}
}
export type AssetManager = typeof(setmetatable({} :: self, AssetManager))

function AssetManager.new(host_instance: Instance, animation_clips: {[AnimationClip]: Animation}?): AssetManager
    if not host_instance then
	error("HostInstance must be passed, if using a different name than `Assets`, please set a string attribute in ReplicatedStorage with the name `ASSET_MANAGER_DIR`")
    end

    local self = setmetatable({} :: self, AssetManager)

    self.host = host_instance
    self.animation_clips = animation_clips or {}

    if not animation_clips then
	self:_initializeAnimationClips()
    end

    return self
end

function AssetManager._initializeAnimationClips(self: AssetManager)
    if RunService:IsServer() then
	for _, asset in self.host:GetDescendants() do
	    if asset:IsA("AnimationClip") then
		if RunService:IsStudio() then
		    local temporary_id = AnimationClipProvider:RegisterAnimationClip(asset)
		    local animation = Instance.new("Animation")
		    animation.Name = `ANIMATION_{asset.Name}`
		    animation.AnimationId = temporary_id
		    animation.Parent = asset
		    self.animation_clips[asset] = animation
		else
		    warn(`{asset:GetFullName()} is still an AnimationClip, animation must be saved to roblox`)
		end
	    end
	end
    else
	for _, asset in self.host:GetDescendants() do
	    if asset:IsA("AnimationClip") then
		local animation = asset:WaitForChild(`ANIMATION_{asset.Name}`) :: Animation
		assert(animation:IsA("Animation"), `The child parented to {asset:GetFullName()} must be an animation (handled by the server).`)
		self.animation_clips[asset] = animation
	    end
	end
    end
end

function AssetManager.GetAsset(self: AssetManager, path: string): Instance
    local asset = self.host
    for _, child_name in path:split("/") do
	local new_asset = asset:FindFirstChild(child_name)
	if not new_asset then
	    error(`AssetManager: {path}: cannot find {child_name}`)
	end
	asset = new_asset
    end
    return asset
end

function AssetManager.GetAnimation(self: AssetManager, path: string): Animation
    local asset = self:GetAsset(path)
    if not asset:IsA("Animation") and not asset:IsA("AnimationClip") then
	error(`AssetManager: {path}: requested as an animation, but is a {asset.ClassName}`)
    end
    return self.animation_clips[asset :: AnimationClip] or asset :: Animation
end

function AssetManager.Curry(self: AssetManager, path: string): AssetManager
    local new = AssetManager.new(self:GetAsset(path), self.animation_clips)
    return new
end

return AssetManager.new(ReplicatedStorage:WaitForChild(ReplicatedStorage:GetAttribute("ASSET_MANAGER_DIR") or "Assets"))
