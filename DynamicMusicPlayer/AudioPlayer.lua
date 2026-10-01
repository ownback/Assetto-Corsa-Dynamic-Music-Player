-- Cross-platform audio backend for Dynamic Music Player.
--
-- The original app relied on ui.MediaPlayer (CSP Media API), which decodes audio via
-- Microsoft Media Foundation and only works when Windows Media Player / its codecs are
-- installed. That breaks on Linux (Proton/Wine) and on debloated Windows installs.
-- This backend prefers FMOD (the audio engine built into the game) via
-- ac.AudioEvent.fromFile, which works identically on Windows and Linux, and keeps
-- ui.MediaPlayer as an automatic fallback for CSP builds without ac.AudioEvent.fromFile.
--
-- Backends (auto-detected at startup, visible in the Debug tab):
--   'fmod' - ac.AudioEvent.fromFile: plays MP3/OGG/FLAC/WAV on Windows and Linux
--   'mmf'  - ui.MediaPlayer: Windows only, requires Windows Media codecs
--   'none' - no working backend: dead silent tracks are returned, app shows a warning
--
-- The track wrapper mimics the ui.MediaPlayer interface used by DynamicMusicPlayer.lua
-- (:play(), :setVolume(), :volume(), :currentTime(), :duration(), :setCurrentTime())
-- plus :isValid() and :dispose().

local AudioPlayer = {}

local loggedReasons = {}

local function preciseClock()
    if os.preciseClock then return os.preciseClock() end
    return os.time()
end

local function logOnce(reason)
    if not loggedReasons[reason] then
        loggedReasons[reason] = true
        ac.log('DynamicMusicPlayer: ' .. reason)
    end
end

-- Silent placeholder used when a track cannot be loaded or no backend exists. It reports
-- itself as finished right away, so the app's existing skip logic moves to the next track.
local function deadTrack(reason)
    logOnce(reason)
    return {
        backend = 'dead',
        dead = true,
        setVolume = function(s, v) end,
        volume = function(s) return 0 end,
        play = function(s) end,
        pause = function(s) end,
        stop = function(s) end,
        currentTime = function(s) return 1 end,
        duration = function(s) return 1 end,
        setCurrentTime = function(s, t) end,
        isValid = function(s) return false end,
        dispose = function(s) end,
    }
end

local function fmodTrack(path)
    if path == nil then return nil end
    local ok, event = pcall(ac.AudioEvent.fromFile, { filename = path, use3D = false, loop = false }, false)
    if not ok or event == nil then
        return nil
    end
    event.cameraInteriorMultiplier = 1
    event.cameraExteriorMultiplier = 1
    event.cameraTrackMultiplier = 1

    local track = {
        backend = 'fmod',
        _event = event,
        _started = false,
        _stopped = false,
        _disposed = false,
        _knownDuration = -1,
        _playClock = 0,
    }

    local function ended()
        if track._stopped or track._disposed then return true end
        -- Events loaded from a file with loop = false become invalid once they finish.
        if track._started and not event:isValid() then return true end
        return false
    end

    local function duration()
        local d = event:getDuration()
        if d and d >= 0 then
            track._knownDuration = d
            return d
        end
        if track._knownDuration >= 0 then return track._knownDuration end
        return 600 -- Fallback while the real duration is not available yet
    end

    local function currentTime()
        if ended() then return duration() end
        local p = event:getTimelinePosition()
        if p and p >= 0 then return p end
        if track._started then return math.min(preciseClock() - track._playClock, duration()) end
        return 0
    end

    function track:play()
        event:resume()
        track._started = true
        track._stopped = false
        track._playClock = preciseClock()
        return self
    end

    function track:stop()
        event:stop()
        track._stopped = true
        return self
    end

    function track:setVolume(v)
        event.volume = math.max(0, v or 0)
        return self
    end

    function track:volume()
        return event.volume
    end

    function track:currentTime()
        return currentTime()
    end

    function track:duration()
        return duration()
    end

    function track:setCurrentTime(t)
        t = math.max(0, tonumber(t) or 0)
        local d = duration()
        if d > 0 and t >= d - 0.05 then
            -- Same semantics as skipping to the end of the track
            event:stop()
            track._stopped = true
        else
            event:seek(t)
            track._playClock = preciseClock() - t
        end
        return self
    end

    function track:isValid()
        return not ended()
    end

    function track:dispose()
        if track._disposed then return self end
        track._disposed = true
        pcall(function() event:stop() end)
        pcall(function() event:dispose() end)
        return self
    end

    return track
end

local function mmfTrack(player)
    local track = { backend = 'mmf', _player = player }

    function track:play() player:play() return self end
    function track:stop()
        player:pause()
        player:setCurrentTime(player:duration())
        return self
    end
    function track:setVolume(v) player:setVolume(v) return self end
    function track:volume() return player:volume() end
    function track:currentTime() return player:currentTime() end
    function track:duration() return player:duration() end
    function track:setCurrentTime(t) player:setCurrentTime(t) return self end
    function track:isValid() return player:hasAudio() end
    function track:dispose()
        pcall(function()
            player:setVolume(0)
            player:setCurrentTime(player:duration())
        end)
        return self
    end

    return track
end

AudioBackend = 'none'
if type(ac) == 'table' and ac.AudioEvent ~= nil and type(ac.AudioEvent.fromFile) == 'function' then
    AudioBackend = 'fmod'
else
    local ok, supported = false, false
    if type(ui) == 'table' and ui.MediaPlayer ~= nil and type(ui.MediaPlayer.supported) == 'function' then
        ok, supported = pcall(ui.MediaPlayer.supported)
    end
    if ok and supported then AudioBackend = 'mmf' end
end

local lastFmodTrack = nil

function AudioPlayer.create(path)
    -- Explicitly release the previous FMOD event to avoid overlapping audio channels
    if lastFmodTrack ~= nil then
        lastFmodTrack:dispose()
        lastFmodTrack = nil
    end

    if AudioBackend == 'fmod' then
        local track = fmodTrack(path)
        if track == nil then
            return deadTrack('Failed to load audio file via FMOD: ' .. tostring(path))
        end
        lastFmodTrack = track
        return track
    end

    if AudioBackend == 'mmf' then
        local ok, player = pcall(ui.MediaPlayer, path)
        if not ok or player == nil then
            return deadTrack('Failed to load audio file via Media Player: ' .. tostring(path))
        end
        return mmfTrack(player)
    end

    return deadTrack('No working audio backend available, please update Custom Shaders Patch')
end

function AudioPlayer.backend()
    return AudioBackend
end

return AudioPlayer