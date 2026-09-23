# Converting Unsupported Audio Files to WAV

> Source: https://www.3cx.com/docs/converting-wav-file/

3CX allows you to import audio files in this format to use as the system prompts:

- **Format:** WAV
- **Channel:** Mono
- **Bit rate:** 8 kHz
- **Sampling:** 16 bit

You need to convert to this format any prompts for IVR, Queues and custom system prompt sets.

## Convert to Wav with the 3CX Online Audio Converter

Automatically convert an audio file to the appropriate format with the 3CX Online Audio Converter:

1. Drag-and-drop the audio file in the upload area or click on the box to select and upload.
2. After the conversion finishes, click on "Download" to save the converted audio file.

**Limits:** max file 50 MB, max duration 15 min, max channels 8.

## Manually Convert an Audio File (Using Audacity)

To convert an audio file using the free Audacity audio editor:

1. Download and install Audacity.
2. Open Audacity, click on "File" > "Open" and select the file you want to convert.
3. Review audio track properties via Audio Setup > Audio Settings.
4. Change the "Project Rate (Hz)" on the bottom status bar to **8000** (8 kHz).
5. If using a stereo file, click the three dots in the track editor and select "Split Stereo to Mono". Click the "X" button to remove the second track.
6. Click on "File" > "Export Audio":
   - Enter a name for the file (latin character set only).
   - Set "Save as type" to **"WAV (Microsoft) signed 16-bit PCM"**.
7. Click "Save".

## Upload Converted Audio Files to 3CX

To upload the exported file(s) via the 3CX Admin Console, go to:

- **"Digital Receptionist"** — upload converted audio files in IVR menus.
- **"Call Queues"** — upload converted audio files for intro prompts and on-hold music.
- **"Settings" > "System Prompts"** — for custom prompt sets.
- **"Settings" > "Music on Hold"** — update on-hold music or playlist.

## See Also

- How to Localize Audio Prompt Sets
- How to Configure IVR / Auto Attendant
- How to Create Call Queues
- How to create 3CX supported System Prompts Set

*Last Updated: 04 June 2026*
