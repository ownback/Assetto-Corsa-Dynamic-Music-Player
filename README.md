Dynamic Music Player for Assetto Corsa!
Music Player that reacts to what's happening on the track, controlling music playlists and volume!

This is a cross-platform fork of [Dynamic Music Player](https://github.com/Damgam/Assetto-Corsa-Dynamic-Music-Player) by [Damgam](https://github.com/Damgam). The original app relied on the CSP Media API, which depends on Windows Media Player being installed. Since 5.0, music is played through FMOD (the audio engine built into the game itself), so the app works on Windows as well as on Linux setups running Assetto Corsa through Proton/Wine, and on debloated Windows installs without Windows Media Player.

IMPORTANT: IF YOU UPDATE FROM ANY OLDER VERSION INTO 5.0+, FRESH INSTALL IS HIGHLY RECOMMENDED. A LOT OF THINGS HAVE CHANGED AND YOUR APP WILL LIKELY MISBEHAVE IF YOU DON'T WIPE OFF ALL THE REMNANTS OF THE OLD VERSION. COPY YOUR MUSIC FOLDER SOMEWHERE, AND RE-ADD YOUR MUSIC TO NEW FOLDERS AFTER THE REINSTALL.

REQUIRES CUSTOM SHADERS PATCH 0.2.2 OR LATER. LATEST CSP IS STRONGLY RECOMMENDED!

Older versions of CSP may work but I don't guarantee it. The FMOD playback backend (`ac.AudioEvent.fromFile`) is used automatically whenever your CSP version has it - if it doesn't, the app falls back to the old Windows-only backend (Windows Media Player required), or shows a warning in the settings app if nothing is available. You can check which backend is active in the Debug tab of the settings app.

Platform support:

- Windows: works out of the box on any CSP version (full Windows installs also get the legacy Windows Media Foundation fallback for formats FMOD doesn't decode).
- Linux: run Assetto Corsa through Proton (Steam) or Wine with CSP installed as usual. Use a recent CSP version (latest preview/release recommended) so the FMOD backend is available.
- If music doesn't play, open the settings app Debug tab and check "Audio Backend". 'fmod' is the cross-platform backend, 'mmf' is the Windows-only fallback, 'none' means you need to update CSP.

Supported audio formats: MP3, OGG Vorbis, FLAC and WAV (decoded by FMOD on all platforms). On Windows with the legacy fallback backend, anything Windows Media Player can decode also works (e.g. WMA, M4A). When in doubt, use MP3/OGG/FLAC.

Download: https://github.com/ownback/Assetto-Corsa-Dynamic-Music-Player/releases

Original mod by Damgam: https://github.com/Damgam/Assetto-Corsa-Dynamic-Music-Player/releases
Also available on https://www.overtake.gg/downloads/dynamic-music-player.65459/

Installation: Copy the DynamicMusicPlayer folder into assettocorsa\apps\lua folder.

Music Install: Copy your music files into assettocorsa\apps\lua\DynamicMusicPlayer\Music\ folders.

ALL THE FOLDERS, EXCEPT THE *OTHER* FOLDER, ARE OPTIONAL.

More details on how to install music:

Make sure you include music at least in the 'Other' folder. That one serves as a fallback for every other folder, if it's left empty, but also as music source for all gamemodes that are not practice, qualification and race.Every other folder can be left empty, and adding any music into them, makes these playlist not use the Other music.
For Finish music to work, there must be some music in the Finish folder. Don't just add music to the FinishPodium folder, it will then be ignored. However, the other way around works perfectly fine, and if FinishPodium is left empty, but Finish is not, it will just play Finish folder music on every finish!
For advanced users, there's a Lua file left in the Music folder, where they can specify paths to other folders in their system to take music from. BEWARE, make sure these folders don't contain any files that are not music. Images, text files, and similar stuff might break the app. I am also not taking any responsibility for anyone breaking that file. On Linux, use paths like "/home/youruser/Music/Race" (forward slashes on all platforms).
Corrupt or unsupported files are now skipped safely instead of crashing the app, but keeping only audio files in your music folders is still recommended.

Features of this app:

- Fully automated playlist creation, just drag and drop your audio files to folders,
- Dedicated playlist for idle, practice, qualification, race, finish and replay sessions,
- Dynamic volume adjustments, reducing volume of the music when you're driving slow, crashing, have opponents nearby or when yellow and blue flags pop up,
- Configurability via ingame Settings app. You can make it as complex or as simple as you like,
- On-screen widget showing you currently playing track,
- Cross-platform playback (Windows and Linux/Proton).

Known Issues:
- Audio formats not supported by FMOD (e.g. M4A/AAC, WMA) only play on Windows when the legacy Windows Media Foundation fallback backend is active.
- If you find any other bugs, please report them in GitHub Issues Page

Credits:
- Dynamic Music Player by Damgam (MIT licensed) - https://github.com/Damgam/Assetto-Corsa-Dynamic-Music-Player
- Cross-platform FMOD playback backend by ownback
