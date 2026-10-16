# push-with-token.ps1 -- push this site to GitHub Pages using a Personal Access Token
#
# Copied from the darkcoffin-wiki repo's script (which is known to work), adapted
# for this site. CHANGE THE TWO CONSTANTS BELOW before running.
#
# WHY A TOKEN (do not skip this):
#   The browser OAuth popup inherits whichever GitHub account is already signed
#   in, so it silently authenticates as the WRONG account and you get
#   "403 Permission denied to <some other account>". A token does not depend on
#   the browser session at all.
#
# CREDENTIALS ARE STORED PER HOST, NOT PER ACCOUNT:
#   Windows Credential Manager keeps ONE entry for "git:https://github.com".
#   This machine currently has one belonging to the OLD account (darkcoffin-wiki).
#   This script deletes it first, then writes the new one -- that order matters.
#
# BEFORE RUNNING:
#   1. Signed in as the NEW account (use a private/incognito window):
#        https://github.com/settings/tokens  ->  Generate new token (classic)
#        scope: tick the whole "repo" block. Copy it (starts with ghp_).
#   2. The repo must already exist on GitHub, empty and PUBLIC, named exactly
#      "<account>.github.io" (no README / .gitignore / license).
#
# RUN (from the site folder):
#     powershell -ExecutionPolicy Bypass -File .\push-with-token.ps1
#
# NOTE: intentionally ASCII-only. Windows PowerShell 5.1 reads script files as
# ANSI/GBK unless they carry a UTF-8 BOM, which would mangle any non-ASCII text.

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- CHANGE ME --
$repo = 'darkcoffin-game/darkcoffin-game.github.io'   # <account>/<repo>
$user = 'darkcoffin-game'                             # the NEW account name
$mail = '604926574@qq.com'                            # commit author email
# ------------------------------------------------------------------------------

Write-Host "==== push to $repo with a token ====" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path '.git')) {
    Write-Host "[ERROR] not a git repo. cd to the site folder first." -ForegroundColor Red
    exit 1
}
Write-Host "working dir: $((Get-Location).Path)"
Write-Host "files to be published:"
Get-ChildItem -File | Where-Object { $_.Name -notlike '.*' } | ForEach-Object { Write-Host ("  {0,-18} {1,8} bytes" -f $_.Name, $_.Length) }
Write-Host ""

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

git remote remove origin 2>$null
git remote add origin "https://github.com/$repo.git"
Write-Host "remote = $(git remote get-url origin)"

git config user.name $user
git config user.email $mail
git config core.quotepath false

Write-Host ""
Write-Host "staging and committing any changes ..." -ForegroundColor Cyan
git add -A
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "  (nothing new to commit)"
} else {
    git commit -m "update site" | Out-Null
    Write-Host "  committed"
}

Write-Host ""
Write-Host "pushing ..." -ForegroundColor Cyan
$env:GIT_TERMINAL_PROMPT = '0'
$env:GCM_INTERACTIVE = 'never'
git push -u origin main
$code = $LASTEXITCODE

Write-Host ""
if ($code -eq 0) {
    Write-Host "[OK] push succeeded." -ForegroundColor Green
    Write-Host "     site: https://$($repo.Split('/')[0]).github.io/   (live within 1-2 minutes)"
    Write-Host "     custom domain: darkcoffin-game.hubingsf.cn"
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
