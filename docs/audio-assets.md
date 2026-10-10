# Kül Çemberi audio catalogue

All runtime audio in `assets/audio/` is original procedural material for this
project. It was generated from the editable deterministic synthesizer at
`tool/generate_audio_assets.py`; no game recording, soundtrack, or extracted
asset was used.

Regenerate the catalogue with:

```powershell
python tool/generate_audio_assets.py
```

The generator requires Python 3.10+, NumPy, and FFmpeg with `libmp3lame`.
Music and intermission stingers are stereo MP3 at 22.05 kHz; short effects and
arena beds are stereo 16-bit PCM WAV at 22.05 kHz.

## Music

| Asset | Runtime use |
| --- | --- |
| `music/menu_theme.mp3` | Title screen |
| `music/chapter_1.mp3`–`chapter_4.mp3` | Four campaign chapters |
| `music/champion_1.mp3`–`champion_4.mp3` | Chapter champions |
| `music/champions_road.mp3` | Post-campaign mastery series |
| `stingers/intermission_1.mp3`–`intermission_4.mp3` | Chapter intermissions |

## Arena ambience

| Asset | Arena |
| --- | --- |
| `ambience/harbor.wav` | Kül Rıhtımı |
| `ambience/forge.wav` | Kor Ocağı |
| `ambience/observatory.wav` | Fırtına Gözlemevi |
| `ambience/tide.wav` | Gelgit Amfitiyatrosu |
| `ambience/fortress.wav` | Taç Kalesi |
| `ambience/crown_ring.wav` | Taç Halkası |

## Sound effects

`ui_confirm`, `ui_back`, `battle_start`, `attack_quick`, `attack_heavy`,
`arrow`, `spell`, `block`, `hit`, `miss`, `status`, `hazard`, `heal`,
`victory`, `defeat`, `reward`, `level_up`, and `contract` are short stereo WAV
files in `sfx/`. The battle event-to-cue map and independent music/SFX levels
are implemented in `lib/game/ui/audio_service.dart`.
