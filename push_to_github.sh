#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# push_to_github.sh
# Run this ONCE in your terminal to create the GitHub repo and push the site.
# ─────────────────────────────────────────────────────────────────────────────

set -e

# ── 1. Enter your GitHub username and a personal access token ────────────────
#       Token needs: repo (full control of private repositories)
#       Create at: https://github.com/settings/tokens/new
read -p "GitHub username: " GH_USER
read -s -p "GitHub personal access token: " GH_TOKEN
echo ""

REPO_NAME="ibm-internship-portfolio"
REPO_DESC="IBM Software Data & AI Intern — Summer 2026 Project Portfolio"

# ── 2. Create the remote repo via GitHub API ────────────────────────────────
echo "Creating repo '$REPO_NAME' on GitHub..."
curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESC\",\"private\":false,\"auto_init\":false}" \
  | python3 -c "import sys,json; r=json.load(sys.stdin); print('Repo URL:', r.get('html_url','ERROR: '+str(r)))"

# ── 3. Set remote and push ──────────────────────────────────────────────────
git remote remove origin 2>/dev/null || true
git remote add origin "https://${GH_USER}:${GH_TOKEN}@github.com/${GH_USER}/${REPO_NAME}.git"
git push -u origin main

# ── 4. Enable GitHub Pages (deploy from main branch / root) ─────────────────
echo "Enabling GitHub Pages..."
curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${GH_USER}/${REPO_NAME}/pages" \
  -d '{"source":{"branch":"main","path":"/"}}' \
  | python3 -c "import sys,json; r=json.load(sys.stdin); print('Pages URL:', r.get('html_url','(enabling — check in ~60s)'))"

echo ""
echo "✅ Done! Your portfolio will be live at:"
echo "   https://${GH_USER}.github.io/${REPO_NAME}/"
echo ""
echo "   (GitHub Pages may take 1–2 minutes to go live after the first push)"
