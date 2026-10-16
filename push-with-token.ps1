# push-with-token.ps1 -- LEGACY / FALLBACK ONLY.
#
#   This site now pushes over SSH (see README.md), which needs no token and no
#   account switching. Keep this script for a machine that has no SSH key set up.
#
# push this site to GitHub Pages using a Personal Access Token
#
# Adapted from the darkcoffin-wiki repo's script (known to work) for this site.
#
# WHY A TOKEN (do not skip this):
#   The browser OAuth popup inherits whichever GitHub account is already signed
#   in, so it silently authenticates as the WRONG account and you get
#   "403 Permission denied to <some other account>". A token does not depend on
#   the browser session at all.
#
# CREDENTIALS ARE STORED PER HOST, NOT PER ACCOUNT:
#   Windows Credential Manager keeps ONE entry for "git:https://github.com".
#   This script deletes the old one first, then writes the new one.
#
# POWERSHELL 5.1 PITFALL (this bit the first version of this script):
#   With $ErrorActionPreference = 'Stop', ANY stderr output from a native
#   command becomes a terminating error. `git remote remove origin` writes
#   "No such remote" to stderr when origin does not exist yet, and `git push`
#   writes its progress to stderr -- so a *successful* push would also abort.
#   Fix: RunGit below runs git with the preference temporarily set to Continue
#   and merges stderr into normal output. Never call git directly here.
#
# USAGE
#   powershell -ExecutionPolicy Bypass -File .\push-with-token.ps1
#   powershell -ExecutionPolicy Bypass -File .\push-with-token.ps1 -DryRun
#       (-DryRun: does everything except reading the token and pushing.
#        Use it to check the local setup without a token.)
#
# NOTE: intentionally ASCII-only. Windows PowerShell 5.1 reads script files as
# ANSI/GBK unless they carry a UTF-8 BOM, which would mangle non-ASCII text.

param([switch]$DryRun)

# --------------------------------------------------------------- CONFIGURE --
$repo  = 'darkcoffin-game/darkcoffin-game.github.io'   # <account>/<repo>
$user  = 'darkcoffin-game'                             # the account name
$mail  = '604926574@qq.com'                            # commit author email
$domain = 'darkcoffin-game.hubingsf.cn'                # custom domain (CNAME)
# ------------------------------------------------------------------------------

$ErrorActionPreference = 'Stop'

function RunGit {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git @GitArgs 2>&1 | ForEach-Object {
            $line = "$_"
            if ($line.Trim()) { Write-Host "    $line" -ForegroundColor DarkGray }
        }
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
}

Write-Host "==== push to $repo ====" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path '.git')) {
    Write-Host "[ERROR] not a git repo. cd to the site folder first." -ForegroundColor Red
    exit 1
}
Write-Host "working dir: $((Get-Location).Path)"
if ($DryRun) { Write-Host "MODE: -DryRun (no token, no push)" -ForegroundColor Yellow }
Write-Host ""

Write-Host "will be published (tracked files):"
git ls-files | ForEach-Object { Write-Host ("    $_") }
Write-Host "  (files listed in .gitignore, e.g. serve.py, are NOT published)" -ForegroundColor DarkGray
Write-Host ""

# --- token ------------------------------------------------------------------
if (-not $DryRun) {
    Write-Host "Paste the token for account '$user' (starts with ghp_), then Enter." -ForegroundColor Yellow
    Write-Host "Input is hidden and does NOT go into shell history." -ForegroundColor DarkGray
    $sec = Read-Host -AsSecureString
    $token = [System.Net.NetworkCredential]::new('', $sec).Password
    if ([string]::IsNullOrWhiteSpace($token)) {
        Write-Host "[ERROR] empty token, aborting." -ForegroundColor Red
        exit 1
    }
    if ($token -notmatch '^(ghp_|github_pat_)') {
        Write-Host "[WARN] this does not look like a GitHub token; trying anyway." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "clearing the OLD credential for git:https://github.com ..." -ForegroundColor Cyan
    cmdkey /delete:"LegacyGeneric:target=git:https://github.com" 2>$null | Out-Null
    Write-Host "storing the new one for '$user' ..." -ForegroundColor Cyan
    cmdkey /generic:"LegacyGeneric:target=git:https://github.com" /user:$user /pass:$token | Out-Null
}

# --- remote (check first: never call `remote remove` on a missing remote) ----
$url = "https://github.com/$repo.git"
$existing = @(git remote) | ForEach-Object { "$_".Trim() }
if ($existing -contains 'origin') {
    Write-Host ""
    Write-Host "origin exists -> updating its URL ..." -ForegroundColor Cyan
    RunGit remote set-url origin $url | Out-Null
} else {
    Write-Host ""
    Write-Host "no origin yet -> adding it ..." -ForegroundColor Cyan
    RunGit remote add origin $url | Out-Null
}
Write-Host "remote = $(git remote get-url origin)"

RunGit config user.name $user | Out-Null
RunGit config user.email $mail | Out-Null
RunGit config core.quotepath false | Out-Null

# --- commit -----------------------------------------------------------------
Write-Host ""
Write-Host "staging ..." -ForegroundColor Cyan
RunGit add -A | Out-Null
& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "  (nothing new to commit)"
} else {
    Write-Host "  committing ..." -ForegroundColor Cyan
    RunGit commit -m "update site" | Out-Null
}

if ($DryRun) {
    Write-Host ""
    Write-Host "[DRY RUN OK] local setup is fine." -ForegroundColor Green
    Write-Host "  next: rerun without -DryRun and paste the token."
    exit 0
}

# --- push -------------------------------------------------------------------
Write-Host ""
Write-Host "pushing ..." -ForegroundColor Cyan
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'never'
$code = RunGit push -u origin main

Write-Host ""
if ($code -eq 0) {
    Write-Host "[OK] push succeeded." -ForegroundColor Green
    Write-Host "     site: https://$($repo.Split('/')[0]).github.io/   (live within 1-2 minutes)"
    Write-Host "     custom domain: $domain"
    Write-Host "       - CNAME file is already in the repo"
    Write-Host "       - DNS: add a CNAME record  darkcoffin-game -> $($repo.Split('/')[0]).github.io"
    Write-Host "       - GitHub: Settings > Pages > Custom domain, then tick Enforce HTTPS"
} else {
    Write-Host "[FAIL] push failed (exit code $code)" -ForegroundColor Red
    Write-Host "  * 403 denied to some other account -> the token belongs to the wrong account;"
    Write-Host "    generate a new one while signed in as $user (private window)."
    Write-Host "  * 403 denied to $user -> the stored credential is stale; rerun this script."
    Write-Host "  * 404 not found -> repo does not exist yet: https://github.com/$repo"
    Write-Host "  * timeout / cannot connect -> proxy:"
    Write-Host "    git config --global http.proxy http://127.0.0.1:PORT"
    Write-Host "  * bad credentials -> rerun this script, or clear with:"
    Write-Host "    cmdkey /delete:LegacyGeneric:target=git:https://github.com"
    Write-Host "  * failed to push some refs -> remote already has commits:"
    Write-Host "    git pull --rebase origin main   then push again"
}
