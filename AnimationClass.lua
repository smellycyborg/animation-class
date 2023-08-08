local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Signal = require(Packages.Signal)

local animation = {}
local animationPrototype = {}
local animationPrivate = {}

function animation.new(id: number)
	assert(id, "Attempt to index nil with id.")
	
	local self = {}
	local private = {}
	
	self.ended = Signal.new()
	
	private.animation = Instance.new("Animation")
	private.animation.AnimationId = "http://www.roblox.com/asset/?id=" .. id
	
	private.tracks = {}
	private.playersPlaying = {}
	
	animationPrivate[self] = private
	
	return setmetatable(self, animationPrototype)
end

function animationPrototype:setTrack(player: Player)
	assert(player, "Attempt to index nil with player.")
	
	local private = animationPrivate[self]
	
	local character = player.Character
	if not character then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end
	
	local animator = humanoid:FindFirstChild("Animator")
	if not animator then
		return
	end
	
	if table.find(private.playersPlaying, player) then
		return
	end
	
	local function trackEnded()
		self.ended:Fire(player)
	end
	
	local track = animator:LoadAnimation(private.animation)
	track.Ended:Connect(trackEnded)
	
	private.tracks[player] = track
end

function animationPrototype:play(player: Player, isLooped: boolean)
	assert(player, "Attempt to index nil with player.")
	
	local private = animationPrivate[self]
	
	local track = private.tracks[player]
	track:Play()
	
	table.insert(private.playersPlaying, player)
	
	if isLooped then
		task.spawn(function()
			while table.find(private.playersPlaying, player) and task.wait() do	
				track:Play()
				track.Ended:Wait()
			end
		end)
	end
end

function animationPrototype:stop(player)
	local private = animationPrivate[self]
	
	table.remove(private.playersPlaying, table.find(private.playersPlaying, player))
	
	if private.tracks[player] then	
		private.tracks[player]:Stop()
		private.tracks[player]:Destroy()
	end
	
	private.tracks[player] = nil
end

function animationPrototype:getPlayersPlaying()
	local private = animationPrivate[self]
	
	return private.playersPlaying
end

function animationPrototype:destroy()
	local private = animationPrivate[self]
	
	private.ended:Destroy()
	
	self = nil
end

animationPrototype.__index = animationPrototype

return animation
