# GitHub Quickstart — Instructions

## What's in here

You got two scripts:

| Script | What it does |
|---|---|
| `github-quickstart.sh` | One-time setup — installs git, logs you into GitHub, and uploads your project |
| `save-and-push.sh` | Run this anytime you want to save your changes to GitHub |

---

## Before you start

- You need a Mac (these scripts are built for macOS)
- You need an internet connection
- You do **not** need anything pre-installed — the script handles everything

---

## Step 1: First-time setup

1. Open **Terminal** (search "Terminal" in Spotlight, or find it in Applications > Utilities)
2. Type this and press Enter:

```
bash /path/to/github-quickstart.sh
```

Replace `/path/to/` with wherever you saved the file. The easiest way:
- Type `bash ` (with a space after it)
- Drag `github-quickstart.sh` from Finder into the Terminal window
- Press Enter

3. Follow the prompts — the script will walk you through everything:
   - Installing developer tools (you may need to click "Install" on a popup)
   - Installing the GitHub CLI
   - Creating a GitHub account (or logging into yours)
   - Picking your project folder (drag it from Finder or type the path)
   - Choosing private or public
   - Pushing everything to GitHub

When it's done, you'll see a link to your project on GitHub.

---

## Step 2: Saving changes (anytime after setup)

Every time you make changes and want to save them to GitHub:

1. Open **Terminal**
2. Type this and press Enter:

```
bash /path/to/save-and-push.sh
```

(Same trick — type `bash ` then drag the script file in.)

3. The script will:
   - Ask where your project is (you can drag the folder in)
   - Show you what files changed
   - Ask you to describe what you changed
   - Save and upload everything to GitHub

That's it. Two scripts, two steps.

---

## Tips

- **Keep both scripts somewhere easy to find**, like your Desktop or Documents folder
- **You only run `github-quickstart.sh` once** per project — after that, just use `save-and-push.sh`
- **Private repos** are only visible to you. You can invite others later from GitHub's website
- If something goes wrong, it's safe to run either script again — they won't break anything

---

## Common questions

**"It says 'permission denied'"**
Run it with `bash` in front:
```
bash github-quickstart.sh
```

**"It's asking for my password"**
Some installs (like Homebrew) need your Mac login password. This is normal — your password won't be shown as you type.

**"I already ran quickstart but I want to add a second project to GitHub"**
Just run `github-quickstart.sh` again and point it at the new folder. It'll skip the stuff that's already installed.

**"I messed something up"**
Nothing the scripts do is destructive. You can always delete the GitHub repo from github.com and start over.
