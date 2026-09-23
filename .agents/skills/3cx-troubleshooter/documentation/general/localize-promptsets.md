# How Can I Localize Prompt Sets?

> Source: https://www.3cx.com/docs/localize-promptsets/

## Introduction

3CX Phone System ships with a set of Prompts Sets for the major languages. In this article, we explain how to localize the Prompts Set, so as to make them available in a language which is not included with the 3CX Phone System.

All prompt sets are located within this folder:

- **Windows:** `%programdata%\3CX\Instance1\Data\Ivr\Prompts\Sets`
- **Linux:** `/var/lib/3cxpbx/Instance1/Data/Ivr/Prompts/Sets`

Each prompt set has a separate sub-directory. For example, the default English prompt set is located within the `...\Sets\8210986B-9412-497f-AD77-3A554F4A9BDB` directory.

### Default Prompt Sets

| Name | ID / Folder Name |
|------|-----------------|
| Australian Prompts Set | 52AUSSIE-f462-4b74-aa85-a1600db86d57 |
| Bulgarian Prompts Set | BULGARIAN-4a4f-4160-b143-488a18be8ba8 |
| Chinese Prompts Set | CHINESEB-9412-497f-AD77-3A554F4A9BDB |
| Czech Prompts Set | CZECH-4b4f-4160-b143-488a18be8ba8 |
| Danish Prompts Set | 2fDANISH-c98b-4cca-b4f6-5049AADC24bb |
| Dutch Prompts Set | 1e6ed594-af95-4bb4-af56-b957ac87d6d7 |
| French Prompts Set | 0D767FEA-10A3-4ba4-8A57-FE74BDABE4E5 |
| German Prompts Set | 03E2DC8C-3382-43e2-A9D5-115F92C847BE |
| Greek Prompts Set | 43EDFDBA-1C46-42d8-A47C-27A86BEFFF76 |
| Italian Prompts Set | 307392E1-F915-4f3a-9362-5049AADC242C |
| Japanese Prompts Set | JAPAN616-A130-47af-A467-30AE7F9AC661 |
| Polish Prompts Set | 8210456B-9412-497f-AD77-3S990T4499MB |
| Portuguese Prompts Set | 1169FAC7-5570-43E3-8C75-AA3A965791E6 |
| Russian Prompts Set | 55RUSSIA-1SS6-4IA8-A47C-27A86BEFF5TF |
| Spanish Prompts Set | F1BAA317-E130-44ff-B467-63AE7F9EC061 |
| Standard English Prompts Set | 8210986B-9412-497f-AD77-3A554F4A9BDB |
| Swedish Prompts Set | 32E3AD5C-3252-4ef2-A9D5-115A92B847AF |
| UK English Prompts Set | 43E89581-DAD8-B6F4-7660-15D48B5E6026 |
| Ukrainian Prompts Set | UKRAINEP-4512-485D-AFGG-UKR54F4A9BDB |

Each prompt set includes the file `SetInfo.xml` which describes the prompts set, and includes the name of the prompt set, the prompts set's version and the definition of the prompts.

## Prompt Set Number Style

By default, 3CX Phone System pronounces the order of numbers as they are pronounced in English. E.g. 21 is pronounced as "twenty one". Some languages pronounce this differently – the numbers are inverted to "one and twenty" (as is the case in German).

The number style is determined by the `<langopts num_style="x">` parameter. When `num_style` is set to `"0"`, the number style used is English-based; when `num_style` is set to `"1"`, the number style used is German-based. E.g. `<langopts num_style="1" />`.

## Prompt Set Translation

In order to create a new Prompt Set, you would need to go through the following steps:

1. Choose the Base Prompt Set
2. Make a Copy of the Prompt Set
3. Create New Audio Files
4. Replace Audio Files
5. Translate Descriptions of Prompts
6. Package the new Prompt Set

> You cannot change the built-in prompt sets, but you can make a copy of a prompt set, which can then be customized.
> When choosing a base prompt set to start from, keep in mind that you need to cater for the grammar style. If you want to create a new prompt set where the grammar is similar to German, then you should use the German prompt set as your base. Otherwise, it is recommended to use a copy of the "Standard English Prompts Set".

### Step 1: Choose the Base Prompt Set

First, you have to choose a prompt set which you will use as the base. You will use this to create your new prompt set. For example, if you want to create a new variant of the English prompt set (e.g. for use in Australia), you are better off using the English prompt set as your base. You can also choose a prompt set in a different language from the 3CX Admin Console in "Settings" > "System Prompts".

### Step 2: Make a Copy of the Prompt Set

In the 3CX Admin Console, go to "System" > "System Prompts" to create a copy of the "Standard English Prompts Set":

- Click "Manage Prompt Sets"
- Ensure "Standard English Prompts Set" is selected.
- Click "Copy".
- Choose a Name for the new Prompts you are going to create; for example "Hungarian Prompts Set" and the ordering of numbers. The default is UK/US number ordering, alternate is German number ordering when the "Use alternate Pronunciation" option is enabled.

The 3CX PBX creates a new directory within the `...\Sets` folder and copies all files from the base prompt set to this folder. The name of the new directory corresponds to the ID of the new prompt set. The ID of the prompt set is a random string generated when the new prompt set is created.

### Step 3: Create New Audio Files

You can create new audio files, containing translated phrases from the base prompt set, by using a speech synthesizer or by recording audio with a microphone. You can then edit audio using your favorite audio editor.

These guidelines apply for creating audio files for prompt sets:

- The supported audio file format is **WAV, PCM, 8 KHz, 16 bit, Mono**.
- Try and keep the size of the .wav files as small as possible.
- Remove silence (more than 10-20 ms) at the beginning and at the end of prompts where possible.
- Avoid abrupt clipping of audio at the end of prompts to avoid audio artifacts (clicks) at the end of prompts.
- Try to create prompts with similar audio characteristics, such as volume, pitch, voice timbre – so that combined phrases sound smooth.
- Do not use reserved characters (`< > : " / \ | ? * &`) for the prompt filename.

### Step 4: Replace Audio Files

You can replace audio files in the 3CX Admin Console in "Settings" > "System Prompts":

- Click on "Manage Prompt Sets", select the prompt set to manage and click "OK".
- Select each prompt to replace and click "Browse" to select an alternate audio file.

### Step 5: Translate Descriptions of Prompts

When changing the content of audio files, you should also change the prompt descriptions.

The `SetInfo.xml` file contains descriptions for all prompts within a prompt set. The descriptions of prompts cannot be changed from the 3CX Admin Console, but can be changed manually in the `SetInfo.xml` file, using a text-editor or xml-editor.

Prompt descriptions can contain international (non-Latin) symbols. There are two ways to insert international characters to a prompt description:

- Use the `&#xHH;` HTML sequences, where `HH` is hexadecimal code for a Unicode character.
- Edit the `SetInfo.xml` file as a UTF-8 file, so you can use any Unicode characters within the prompt description.

### Step 6: Package the new Prompt Set

After you have translated a prompt set (by changing the content of audio files and translated description of prompts), you may want to send this prompt set to another 3CX PBX.

To make a prompt set package, pack the directory of the prompt set (together with files and subfolders) into a RAR or ZIP file. The prompt set directory must contain all the audio files and the `SetInfo.xml` file.

*Last Updated: 02 June 2026*
