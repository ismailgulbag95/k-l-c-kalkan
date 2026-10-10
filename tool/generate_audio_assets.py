"""Generate original procedural music, ambience and combat SFX for Kül Çemberi.

Requires Python 3.10+, NumPy and FFmpeg with libmp3lame. Run from any directory:

    python tool/generate_audio_assets.py

The script is the editable source for the generated runtime assets. It does not
sample or derive audio from Swords and Sandals or any other game.
"""

from __future__ import annotations

import math
import shutil
import subprocess
import tempfile
import wave
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "audio"
SAMPLE_RATE = 22_050
RNG = np.random.default_rng(741_992)


def midi(m: float) -> float:
    return 440.0 * (2.0 ** ((m - 69.0) / 12.0))


def _pan(samples: np.ndarray, pan: float) -> np.ndarray:
    left = math.sqrt((1.0 - pan) * 0.5)
    right = math.sqrt((1.0 + pan) * 0.5)
    stereo = np.empty((samples.size, 2), dtype=np.float32)
    stereo[:, 0] = samples * left
    stereo[:, 1] = samples * right
    return stereo


def _mix(target: np.ndarray, start_seconds: float, samples: np.ndarray, pan: float = 0.0) -> None:
    start = max(0, int(start_seconds * SAMPLE_RATE))
    end = min(target.shape[0], start + samples.size)
    if end <= start:
        return
    shaped = _pan(samples[: end - start], pan)
    target[start:end] += shaped


def _tone(
    frequency: float,
    duration: float,
    amplitude: float,
    *,
    voice: str = "sine",
    attack: float = 0.015,
    release: float = 0.12,
    decay: float = 0.0,
    bend: float = 0.0,
) -> np.ndarray:
    count = max(1, int(duration * SAMPLE_RATE))
    t = np.arange(count, dtype=np.float32) / SAMPLE_RATE
    if bend:
        phase = 2.0 * np.pi * frequency * t + np.pi * bend * t * t / max(duration, 0.01)
    else:
        phase = 2.0 * np.pi * frequency * t
    if voice == "pluck":
        body = np.sin(phase) + 0.34 * np.sin(phase * 2.01) + 0.12 * np.sin(phase * 3.98)
        envelope = np.exp(-t * (decay or 4.2))
    elif voice == "brass":
        body = np.sin(phase) + 0.42 * np.sin(phase * 2) + 0.18 * np.sin(phase * 3)
        envelope = np.minimum(1.0, t / max(attack, 0.01))
        envelope *= np.minimum(1.0, np.maximum(0.0, (duration - t) / max(release, 0.01)))
        envelope = 0.55 + 0.45 * envelope
    elif voice == "bell":
        body = np.sin(phase) + 0.55 * np.sin(phase * 2.74) + 0.24 * np.sin(phase * 5.4)
        envelope = np.exp(-t * (decay or 3.1))
    elif voice == "pad":
        body = np.sin(phase) + 0.18 * np.sin(phase * 2.0) + 0.08 * np.sin(phase * 3.01)
        envelope = np.minimum(1.0, t / max(attack, 0.01))
        envelope *= np.minimum(1.0, np.maximum(0.0, (duration - t) / max(release, 0.01)))
        envelope = 0.35 + 0.65 * envelope
    else:
        body = np.sin(phase)
        envelope = np.minimum(1.0, t / max(attack, 0.005))
        envelope *= np.minimum(1.0, np.maximum(0.0, (duration - t) / max(release, 0.005)))
    return (body * envelope * amplitude).astype(np.float32)


def _noise(duration: float, color: str = "pink") -> np.ndarray:
    count = max(1, int(duration * SAMPLE_RATE))
    white = RNG.normal(0.0, 1.0, count).astype(np.float32)
    if color == "white":
        result = white
    else:
        spectrum = np.fft.rfft(white)
        frequencies = np.fft.rfftfreq(count, 1.0 / SAMPLE_RATE)
        if color == "brown":
            weighting = 1.0 / np.maximum(frequencies, 18.0) ** 0.68
        elif color == "wind":
            weighting = 1.0 / (1.0 + (frequencies / 380.0) ** 1.6)
        else:
            weighting = 1.0 / np.sqrt(np.maximum(frequencies, 18.0))
        result = np.fft.irfft(spectrum * weighting, n=count).astype(np.float32)
        result /= max(float(np.max(np.abs(result))), 1e-6)
    return result


def _kick(duration: float, strength: float = 1.0) -> np.ndarray:
    count = max(1, int(duration * SAMPLE_RATE))
    t = np.arange(count, dtype=np.float32) / SAMPLE_RATE
    phase = 2 * np.pi * (74 * t - 29 * t * t / max(duration, 0.01))
    return (np.sin(phase) * np.exp(-t * 15.0) * strength).astype(np.float32)


def _write_wav(path: Path, samples: np.ndarray, channels: int = 1) -> None:
    samples = np.asarray(samples, dtype=np.float32)
    if samples.ndim == 2:
        channels = samples.shape[1]
    peak = max(float(np.max(np.abs(samples))), 1e-7)
    samples = samples * min(0.92 / peak, 1.0)
    pcm = (np.clip(samples, -1.0, 1.0) * 32767).astype("<i2")
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as target:
        target.setnchannels(channels)
        target.setsampwidth(2)
        target.setframerate(SAMPLE_RATE)
        target.writeframes(pcm.tobytes())


def _encode_mp3(source: Path, destination: Path, ffmpeg: str) -> None:
    subprocess.run(
        [
            ffmpeg,
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-i",
            str(source),
            "-codec:a",
            "libmp3lame",
            "-b:a",
            "80k",
            "-ar",
            str(SAMPLE_RATE),
            "-ac",
            "2",
            str(destination),
        ],
        check=True,
    )


def render_music(
    *,
    tempo: int,
    tonic: int,
    scale: tuple[int, ...],
    intensity: float,
    seed: int,
    bars: int = 16,
) -> np.ndarray:
    rng = np.random.default_rng(seed)
    beat = 60.0 / tempo
    bar = beat * 4
    duration = bar * bars
    mix = np.zeros((int(duration * SAMPLE_RATE), 2), dtype=np.float32)
    progression = (0, 5, 3, 6, 0, 4, 2, 5, 3, 6, 4, 1, 0, 5, 3, 0)
    melody = (0, 2, 4, 2, 5, 4, 2, 1, 0, 2, 4, 6, 5, 3, 2, 0)

    for bar_index in range(bars):
        degree = progression[bar_index % len(progression)]
        root = tonic + scale[degree % len(scale)]
        chord = (root, tonic + scale[(degree + 2) % len(scale)], tonic + scale[(degree + 4) % len(scale)])
        start = bar_index * bar
        for chord_index, note in enumerate(chord):
            _mix(
                mix,
                start,
                _tone(midi(note - 12), bar * 1.08, 0.055 + intensity * 0.018, voice="pad", attack=0.42, release=0.5),
                pan=(-0.32, 0.0, 0.32)[chord_index],
            )
        _mix(mix, start, _tone(midi(root - 24), bar * 0.88, 0.15 + intensity * 0.04, voice="sine", attack=0.04, release=0.18), -0.12)
        _mix(mix, start + beat * 2, _tone(midi(root - 24), beat * 1.7, 0.12 + intensity * 0.03, voice="sine", attack=0.03, release=0.16), 0.12)

        for beat_index in range(4):
            beat_start = start + beat * beat_index
            if beat_index in (0, 2):
                _mix(mix, beat_start, _kick(0.32, 0.22 + intensity * 0.16))
            elif intensity > 0.46:
                snare = _noise(0.17, "white") * np.exp(-np.arange(int(0.17 * SAMPLE_RATE), dtype=np.float32) / SAMPLE_RATE * 18)
                _mix(mix, beat_start, snare * (0.035 + intensity * 0.035), 0.05)
            if beat_index % 2 == 1:
                tick = _noise(0.035, "white") * np.exp(-np.arange(int(0.035 * SAMPLE_RATE), dtype=np.float32) / SAMPLE_RATE * 90)
                _mix(mix, beat_start + beat * 0.5, tick * (0.015 + intensity * 0.025), 0.18)

        for eighth in range(8):
            note_index = melody[(bar_index + eighth) % len(melody)]
            if rng.random() < (0.55 + intensity * 0.22):
                note = tonic + scale[note_index % len(scale)] + 12
                note_duration = beat * (0.34 if eighth % 2 else 0.52)
                pan = float(rng.uniform(-0.55, 0.55))
                _mix(
                    mix,
                    start + beat * eighth * 0.5,
                    _tone(midi(note), note_duration, 0.035 + intensity * 0.026, voice="pluck", decay=3.0),
                    pan,
                )

    # Soft loop edges avoid a click at the release point while all phrases land
    # on complete bars, so the musical pulse remains stable on repeat.
    edge = min(int(0.12 * SAMPLE_RATE), mix.shape[0] // 8)
    fade = np.linspace(0.0, 1.0, edge, dtype=np.float32)
    mix[:edge] *= fade[:, None]
    mix[-edge:] *= fade[::-1, None]
    return mix


def render_stinger(seed: int, root: int, *, triumphant: bool) -> np.ndarray:
    duration = 5.2
    mix = np.zeros((int(duration * SAMPLE_RATE), 2), dtype=np.float32)
    chord = (root, root + (4 if triumphant else 3), root + 7, root + 12)
    for index, note in enumerate(chord):
        _mix(
            mix,
            0.08 + index * 0.045,
            _tone(midi(note + 12), 4.5, 0.14, voice="brass", attack=0.08, release=0.7),
            (index - 1.5) * 0.24,
        )
    _mix(mix, 0.04, _kick(0.75, 0.46))
    noise = _noise(2.2, "white") * np.exp(-np.arange(int(2.2 * SAMPLE_RATE), dtype=np.float32) / SAMPLE_RATE * 3.5)
    _mix(mix, 0.08, noise * 0.055, 0.12 if seed % 2 else -0.12)
    return mix


def render_ambience(duration: float, kind: str, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    count = int(duration * SAMPLE_RATE)
    mix = np.zeros((count, 2), dtype=np.float32)
    wind = _noise(duration, "wind")
    t = np.arange(count, dtype=np.float32) / SAMPLE_RATE
    modulation = 0.66 + 0.24 * np.sin(2 * np.pi * t / duration) + 0.1 * np.sin(2 * np.pi * t / (duration * 0.43))
    wind *= modulation.astype(np.float32) * 0.11
    _mix(mix, 0, wind, -0.15)
    crowd = _noise(duration, "brown") * (0.018 + 0.012 * np.sin(2 * np.pi * t / (duration * 0.31)))
    _mix(mix, 0, crowd.astype(np.float32), 0.18)

    if kind == "harbor":
        for offset in (2.4, 8.8, 15.1, 22.7):
            _mix(mix, offset, _tone(880, 1.0, 0.055, voice="bell", decay=3.6, bend=-190), float(rng.uniform(-0.7, 0.7)))
        _mix(mix, 4.0, _noise(2.6, "wind") * 0.13)
    elif kind == "forge":
        for offset in (1.2, 5.3, 9.6, 14.4, 20.8):
            _mix(mix, offset, _kick(0.22, 0.24), float(rng.uniform(-0.5, 0.5)))
            _mix(mix, offset + 0.05, _noise(0.18, "white") * 0.06)
    elif kind == "storm":
        for offset in (3.0, 11.4, 19.3):
            rumble = _noise(2.9, "brown") * np.linspace(0.02, 0.20, int(2.9 * SAMPLE_RATE), dtype=np.float32)
            _mix(mix, offset, rumble, float(rng.uniform(-0.4, 0.4)))
    elif kind == "tide":
        for offset in (1.7, 7.2, 13.0, 18.4, 24.0):
            swell = _noise(2.8, "wind") * np.sin(np.linspace(0, math.pi, int(2.8 * SAMPLE_RATE), dtype=np.float32)) * 0.15
            _mix(mix, offset, swell, float(rng.uniform(-0.7, 0.7)))
    elif kind == "fortress":
        for offset in (4.6, 12.5, 21.0):
            _mix(mix, offset, _tone(110, 1.8, 0.12, voice="bell", decay=2.8, bend=8), float(rng.uniform(-0.5, 0.5)))
        for offset in (8.1, 17.6):
            _mix(mix, offset, _kick(0.42, 0.18))
    elif kind == "crown":
        for offset in (2.2, 6.6, 10.9, 15.8, 20.0, 24.4):
            _mix(mix, offset, _tone(660, 1.2, 0.035, voice="bell", decay=2.4), float(rng.uniform(-0.8, 0.8)))

    edge = int(0.45 * SAMPLE_RATE)
    fade = np.linspace(0.0, 1.0, edge, dtype=np.float32)
    bridge = mix[-edge:] * (1.0 - fade[:, None]) + mix[:edge] * fade[:, None]
    mix[:edge] = bridge
    mix[-edge:] = bridge
    return mix


def render_sfx(name: str) -> np.ndarray:
    durations = {
        "ui_confirm": 0.22,
        "ui_back": 0.18,
        "battle_start": 1.25,
        "attack_quick": 0.42,
        "attack_heavy": 0.74,
        "arrow": 0.46,
        "spell": 0.85,
        "block": 0.34,
        "hit": 0.29,
        "miss": 0.32,
        "status": 0.62,
        "hazard": 0.9,
        "heal": 0.82,
        "victory": 1.8,
        "defeat": 1.7,
        "reward": 0.7,
        "level_up": 1.05,
        "contract": 0.58,
    }
    duration = durations[name]
    mix = np.zeros((int(duration * SAMPLE_RATE), 2), dtype=np.float32)

    if name == "ui_confirm":
        _mix(mix, 0, _tone(740, 0.11, 0.2, voice="bell", decay=18))
        _mix(mix, 0.055, _tone(1110, 0.16, 0.12, voice="bell", decay=17), 0.1)
    elif name == "ui_back":
        _mix(mix, 0, _tone(360, 0.16, 0.14, voice="sine", bend=-90, decay=13))
    elif name == "battle_start":
        _mix(mix, 0.05, _kick(0.62, 0.52))
        _mix(mix, 0.08, _tone(146.8, 0.95, 0.19, voice="brass", attack=0.06, release=0.35))
        _mix(mix, 0.14, _tone(220, 0.8, 0.11, voice="brass", attack=0.1, release=0.4), -0.24)
    elif name in ("attack_quick", "miss"):
        whoosh = _noise(duration, "white") * np.sin(np.linspace(0, math.pi, len(mix), dtype=np.float32))
        _mix(mix, 0, whoosh * (0.12 if name == "attack_quick" else 0.08), -0.15)
        if name == "miss":
            _mix(mix, 0.04, _tone(500, 0.22, 0.09, voice="sine", bend=-310, decay=5))
    elif name == "attack_heavy":
        _mix(mix, 0.02, _kick(0.52, 0.52))
        _mix(mix, 0.19, _tone(190, 0.5, 0.18, voice="bell", bend=-75, decay=4.8), 0.08)
        _mix(mix, 0.2, _noise(0.24, "white") * 0.12, -0.08)
    elif name == "arrow":
        noise = _noise(0.35, "white") * np.linspace(0.42, 0.0, int(0.35 * SAMPLE_RATE), dtype=np.float32)
        _mix(mix, 0.02, noise * 0.16, 0.25)
        _mix(mix, 0.04, _tone(900, 0.3, 0.045, voice="sine", bend=-600, decay=8), -0.2)
    elif name in ("spell", "status"):
        for index, frequency in enumerate((330, 495, 740, 990)):
            _mix(mix, index * 0.11, _tone(frequency, 0.5, 0.08, voice="bell", bend=70, decay=4.2), (-0.45, -0.15, 0.18, 0.48)[index])
        if name == "status":
            crackle = _noise(0.34, "white") * np.linspace(0.08, 0.0, int(0.34 * SAMPLE_RATE), dtype=np.float32)
            _mix(mix, 0.12, crackle * 0.18)
    elif name == "block":
        _mix(mix, 0.02, _tone(280, 0.3, 0.18, voice="bell", bend=-125, decay=7))
        _mix(mix, 0.03, _noise(0.25, "white") * np.linspace(0.14, 0.0, int(0.25 * SAMPLE_RATE), dtype=np.float32))
    elif name == "hit":
        _mix(mix, 0.01, _kick(0.24, 0.38))
        _mix(mix, 0.015, _tone(120, 0.22, 0.1, voice="sine", bend=-44, decay=11))
    elif name == "hazard":
        rumble = _noise(0.75, "brown") * np.sin(np.linspace(0, math.pi, int(0.75 * SAMPLE_RATE), dtype=np.float32))
        _mix(mix, 0.04, rumble * 0.26)
        _mix(mix, 0.18, _tone(92, 0.48, 0.18, voice="sine", bend=-55, decay=4))
    elif name == "heal":
        for index, frequency in enumerate((523.25, 659.25, 783.99, 1046.5)):
            _mix(mix, index * 0.13, _tone(frequency, 0.48, 0.11, voice="bell", decay=3.7), -0.36 + index * 0.24)
    elif name in ("victory", "defeat", "reward", "level_up", "contract"):
        if name == "victory":
            notes = (62, 66, 69, 74)
        elif name == "defeat":
            notes = (62, 59, 55, 50)
        elif name == "level_up":
            notes = (62, 66, 69, 74, 78)
        elif name == "reward":
            notes = (74, 81, 86)
        else:
            notes = (67, 71, 74)
        for index, note in enumerate(notes):
            _mix(mix, index * 0.13, _tone(midi(note), duration - index * 0.13, 0.15, voice="brass" if name in ("victory", "defeat") else "bell", attack=0.05, release=0.42, decay=2.8), -0.38 + index * 0.19)
        _mix(mix, 0, _kick(0.42, 0.25))

    return mix


def main() -> None:
    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        raise SystemExit("FFmpeg with libmp3lame is required to encode the original music loops.")
    OUT.mkdir(parents=True, exist_ok=True)

    themes = {
        "menu_theme": (82, 50, (0, 2, 3, 5, 7, 9, 10), 0.22, 12),
        "chapter_1": (96, 50, (0, 2, 3, 5, 7, 9, 10), 0.36, 21),
        "chapter_2": (108, 45, (0, 2, 4, 5, 7, 9, 11), 0.58, 32),
        "chapter_3": (116, 50, (0, 1, 3, 5, 7, 8, 10), 0.68, 43),
        "chapter_4": (102, 48, (0, 2, 4, 5, 7, 9, 10), 0.72, 54),
        "champion_1": (118, 50, (0, 2, 3, 5, 7, 9, 10), 0.84, 65),
        "champion_2": (126, 45, (0, 2, 4, 5, 7, 9, 11), 0.92, 76),
        "champion_3": (132, 50, (0, 1, 3, 5, 7, 8, 10), 0.96, 87),
        "champion_4": (120, 48, (0, 2, 4, 5, 7, 9, 10), 1.0, 98),
        "champions_road": (126, 50, (0, 2, 3, 5, 7, 9, 10), 0.94, 109),
    }
    with tempfile.TemporaryDirectory(prefix="kul_cember_audio_") as temp:
        temp_path = Path(temp)
        for index, (name, (tempo, tonic, scale, intensity, seed)) in enumerate(themes.items()):
            print(f"Rendering music {index + 1}/{len(themes)}: {name}")
            rendered = render_music(tempo=tempo, tonic=tonic, scale=scale, intensity=intensity, seed=seed)
            wav = temp_path / f"{name}.wav"
            _write_wav(wav, rendered, channels=2)
            destination = OUT / "music" / f"{name}.mp3"
            destination.parent.mkdir(parents=True, exist_ok=True)
            _encode_mp3(wav, destination, ffmpeg)

        for index in range(1, 5):
            print(f"Rendering intermission stinger {index}/4")
            wav = temp_path / f"intermission_{index}.wav"
            _write_wav(wav, render_stinger(200 + index, 50 + (index - 1) * 2, triumphant=index % 2 == 0), channels=2)
            destination = OUT / "stingers" / f"intermission_{index}.mp3"
            destination.parent.mkdir(parents=True, exist_ok=True)
            _encode_mp3(wav, destination, ffmpeg)

    arenas = {
        "harbor": "harbor",
        "forge": "forge",
        "observatory": "storm",
        "tide": "tide",
        "fortress": "fortress",
        "crown_ring": "crown",
    }
    for index, (name, kind) in enumerate(arenas.items(), start=1):
        print(f"Rendering arena ambience {index}/{len(arenas)}: {name}")
        rendered = render_ambience(26.0, kind, 310 + index)
        _write_wav(OUT / "ambience" / f"{name}.wav", rendered, channels=2)

    cues = (
        "ui_confirm", "ui_back", "battle_start", "attack_quick", "attack_heavy", "arrow",
        "spell", "block", "hit", "miss", "status", "hazard", "heal", "victory", "defeat",
        "reward", "level_up", "contract",
    )
    for index, name in enumerate(cues, start=1):
        print(f"Rendering sound effect {index}/{len(cues)}: {name}")
        _write_wav(OUT / "sfx" / f"{name}.wav", render_sfx(name), channels=2)

    total = sum(path.stat().st_size for path in OUT.rglob("*") if path.is_file())
    print(f"Generated {sum(1 for path in OUT.rglob('*') if path.is_file())} audio files ({total:,} bytes).")


if __name__ == "__main__":
    main()
