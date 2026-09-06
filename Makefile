# Makefile for the Billo Systems site (billo.systems)
#
# Stock Cobalt + shell scripts — no custom binary. Local preview goes through
# scripts/preview.sh (build + Pagefind index + serve) so search works; do NOT
# use `cobalt serve`, which wipes site/pagefind/. See README.md.

# ANSI color codes
BLUE := \033[1;34m
GREEN := \033[1;32m
YELLOW := \033[1;33m
RED := \033[1;31m
CYAN := \033[1;36m
RESET := \033[0m

# Variables
PROJECT_NAME := Billo Systems Site
PUBLISH_DIR := site
PORT := 1414                      # scripts/preview.sh serves via `pagefind --serve`
GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

.DEFAULT_GOAL := help

#############################################################################
###   HELP   ################################################################
#############################################################################

.PHONY: help
help:
	@echo ""
	@echo "$(CYAN)╔══════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(CYAN)║$(RESET) $(BLUE)$(PROJECT_NAME) Build System$(RESET)                          $(CYAN)║$(RESET)"
	@echo "$(CYAN)╚══════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(GREEN)Site:$(RESET)"
	@echo "  $(YELLOW)make build$(RESET)            - Build the site with Cobalt into ./$(PUBLISH_DIR)/"
	@echo "  $(YELLOW)make serve$(RESET)            - Build + index + local preview WITH search (port $(PORT))"
	@echo "  $(YELLOW)make run$(RESET)              - Alias for 'make serve'"
	@echo "  $(YELLOW)make clean$(RESET)            - Clear the ./$(PUBLISH_DIR)/ build output"
	@echo "  $(YELLOW)make deploy$(RESET)           - Trigger the GitHub Actions Pages deployment workflow"
	@echo ""
	@echo "$(GREEN)Assets & setup (self-hosted, no CDN):$(RESET)"
	@echo "  $(YELLOW)make vendor$(RESET)           - Fetch all vendored assets (fonts, KaTeX, avatars)"
	@echo "  $(YELLOW)make fetch-fonts$(RESET)      - Vendor Fontsource woff2 → assets/fonts/"
	@echo "  $(YELLOW)make fetch-katex$(RESET)      - Vendor KaTeX (js/css/fonts) → assets/katex/"
	@echo "  $(YELLOW)make fetch-avatars$(RESET)    - Vendor author avatars → assets/images/authors/"
	@echo "  $(YELLOW)make install-pagefind$(RESET) - Install the Pagefind search binary"
	@echo ""
	@echo "$(GREEN)Publishing:$(RESET)"
	@echo "  $(YELLOW)make commit-post FILE=<path> MSG=\"<message>\"$(RESET)"
	@echo "                        - Commit a post back-dated to its published_date"
	@echo "  $(YELLOW)make commit-republished FILE=<path> MSG=\"<message>\"$(RESET)"
	@echo "                        - Commit a republished post back-dated to data.republished.original_date"
	@echo ""
	@echo "$(GREEN)Quality:$(RESET)"
	@echo "  $(YELLOW)make check-tags$(RESET)       - Ensure no spaces in post tags (spaces break /tags/ URLs)"
	@echo "  $(YELLOW)make spell-check$(RESET)      - Spell-check posts (needs aspell)"
	@echo ""
	@echo "$(GREEN)Information:$(RESET)"
	@echo "  $(YELLOW)make info$(RESET)             - Show build information"
	@echo "  $(YELLOW)make check-tools$(RESET)      - Verify required tools are installed"
	@echo ""
	@echo "$(CYAN)Current status:$(RESET) Branch: $(GIT_BRANCH) | Commit: $(GIT_COMMIT)"
	@echo ""

#############################################################################
###   SITE   ################################################################
#############################################################################

.PHONY: build
build:
	@echo "$(BLUE)Building $(PROJECT_NAME)...$(RESET)"
	@cobalt build
	@echo "$(GREEN)✓ Build complete → ./$(PUBLISH_DIR)/$(RESET)"

.PHONY: serve
serve:
	@echo "$(BLUE)Building + indexing + serving (search enabled) on port $(PORT)...$(RESET)"
	@./scripts/preview.sh

.PHONY: run
run: serve

.PHONY: clean
clean:
	@echo "$(BLUE)Clearing ./$(PUBLISH_DIR)/ (keeping the git worktree linkage)...$(RESET)"
	@if [ -d $(PUBLISH_DIR) ]; then find $(PUBLISH_DIR) -mindepth 1 -maxdepth 1 -not -name '.git' -exec rm -rf {} +; fi
	@rm -rf _site
	@echo "$(GREEN)✓ Clean complete$(RESET)"

.PHONY: deploy
deploy:
	@command -v gh >/dev/null 2>&1 || { echo "$(RED)error: gh not found (needed to trigger GitHub Actions manually)$(RESET)"; exit 1; }
	@echo "$(BLUE)Triggering the GitHub Actions Pages deployment workflow...$(RESET)"
	@gh workflow run deploy.yml --ref main
	@echo "$(GREEN)✓ Workflow dispatched$(RESET)"

#############################################################################
###   ASSETS & SETUP   ######################################################
#############################################################################

.PHONY: vendor
vendor: fetch-fonts fetch-katex fetch-avatars
	@echo "$(GREEN)✓ All vendored assets refreshed$(RESET)"

.PHONY: fetch-fonts
fetch-fonts:
	@./scripts/fetch-fonts.sh

.PHONY: fetch-katex
fetch-katex:
	@./scripts/fetch-katex.sh

.PHONY: fetch-avatars
fetch-avatars:
	@./scripts/fetch-avatars.sh

.PHONY: install-pagefind
install-pagefind:
	@./scripts/install-pagefind.sh

#############################################################################
###   PUBLISHING   ##########################################################
#############################################################################

# Commit a post with author + committer dates set to its published_date, so the
# git history mirrors the post's (often back-dated) timeline.
#   make commit-post FILE=posts/2026/my-post.md MSG="Add: my post"
.PHONY: commit-post
commit-post:
	@test -n "$(FILE)" || { echo "$(RED)usage: make commit-post FILE=<path> MSG=\"<message>\"$(RESET)"; exit 1; }
	@test -n "$(MSG)"  || { echo "$(RED)usage: make commit-post FILE=<path> MSG=\"<message>\"$(RESET)"; exit 1; }
	@test -f "$(FILE)" || { echo "$(RED)error: no such file: $(FILE)$(RESET)"; exit 1; }
	@DATE=$$(sed -n 's/^published_date:[[:space:]]*//p' "$(FILE)" | head -1); \
	 DATE=$${DATE%\"}; DATE=$${DATE#\"}; \
	 test -n "$$DATE" || { echo "$(RED)error: no 'published_date' in frontmatter of $(FILE)$(RESET)"; exit 1; }; \
	 echo "$(BLUE)→ committing $(FILE)$(RESET) dated $(GREEN)$$DATE$(RESET)"; \
	 GIT_AUTHOR_DATE="$$DATE" GIT_COMMITTER_DATE="$$DATE" git commit -m "$(MSG)" "$(FILE)"

# As commit-post, but for a republished piece: back-date to the ORIGINAL
# publication date (data.republished.original_date, indented in frontmatter)
# rather than published_date (when it went up here).
#   make commit-republished FILE=posts/2026/my-repost.md MSG="Republish: my post"
.PHONY: commit-republished
commit-republished:
	@test -n "$(FILE)" || { echo "$(RED)usage: make commit-republished FILE=<path> MSG=\"<message>\"$(RESET)"; exit 1; }
	@test -n "$(MSG)"  || { echo "$(RED)usage: make commit-republished FILE=<path> MSG=\"<message>\"$(RESET)"; exit 1; }
	@test -f "$(FILE)" || { echo "$(RED)error: no such file: $(FILE)$(RESET)"; exit 1; }
	@DATE=$$(sed -n 's/^[[:space:]]*original_date:[[:space:]]*//p' "$(FILE)" | head -1); \
	 DATE=$${DATE%\"}; DATE=$${DATE#\"}; \
	 test -n "$$DATE" || { echo "$(RED)error: no 'republished.original_date' in frontmatter of $(FILE)$(RESET)"; exit 1; }; \
	 echo "$(BLUE)→ committing $(FILE)$(RESET) dated $(GREEN)$$DATE$(RESET) (original publication)"; \
	 GIT_AUTHOR_DATE="$$DATE" GIT_COMMITTER_DATE="$$DATE" git commit -m "$(MSG)" "$(FILE)"

#############################################################################
###   QUALITY   #############################################################
#############################################################################

# Spaces in a tag break its URL (/tags/graph theory/ → /tags/graph%20theory/).
# Use hyphens (graph-theory). Scans every `tags:` line in posts/.
.PHONY: check-tags
check-tags:
	@echo "$(BLUE)Checking post tags for spaces...$(RESET)"
	@files=$$(grep -rlE '^tags:' posts/ 2>/dev/null); \
	if [ -z "$$files" ]; then echo "$(GREEN)  ✓ no tag metadata found$(RESET)"; exit 0; fi; \
	bad=$$(awk '/^tags:/{l=$$0; sub(/^tags:[ ]*\[?/,"",l); sub(/\].*$$/,"",l); gsub(/ *, */,",",l); gsub(/,/,"",l); if(l ~ / /) print FILENAME":"FNR": "$$0}' $$files); \
	if [ -n "$$bad" ]; then \
		echo "$(RED)  ✗ spaces found in tags (use '-' instead):$(RESET)"; \
		echo "$$bad" | sed 's/^/    /'; \
		exit 1; \
	fi; \
	echo "$(GREEN)  ✓ no spaces in tags$(RESET)"

.PHONY: spell-check
spell-check:
	@command -v aspell >/dev/null 2>&1 || { echo "$(YELLOW)⊙ aspell not installed — skipping$(RESET)"; exit 0; }
	@echo "$(BLUE)Spell-checking posts...$(RESET)"
	@for FILE in $$(find posts -name "*.md" 2>/dev/null); do \
		RESULTS=$$(cat "$$FILE" | aspell -d en_GB --mode=markdown list | sort -u | paste -sd, -); \
		if [ -n "$$RESULTS" ]; then echo "$(YELLOW)  ⊙ $$FILE:$(RESET)"; echo "    $$RESULTS"; fi; \
	done
	@echo "$(GREEN)✓ Spell check complete$(RESET)"

#############################################################################
###   INFORMATION   #########################################################
#############################################################################

.PHONY: info
info:
	@echo ""
	@echo "$(GREEN)Project:$(RESET)  $(PROJECT_NAME)"
	@echo "  Workspace:      $$(pwd)"
	@echo "$(GREEN)Git:$(RESET)"
	@echo "  Branch:         $(GIT_BRANCH)"
	@echo "  Commit:         $(GIT_COMMIT)"
	@echo "$(GREEN)Tools:$(RESET)"
	@echo "  Cobalt:         $$(cobalt --version 2>/dev/null || echo 'not found')"
	@echo "  Pagefind:       $$(pagefind --version 2>/dev/null || echo 'not found (make install-pagefind)')"
	@echo ""

.PHONY: check-tools
check-tools:
	@echo "$(BLUE)Checking for required tools...$(RESET)"
	@command -v cobalt   >/dev/null 2>&1 && echo "$(GREEN)  ✓ cobalt found$(RESET)"   || echo "$(RED)  ✗ cobalt not found (install: cargo install cobalt-bin)$(RESET)"
	@command -v pagefind >/dev/null 2>&1 && echo "$(GREEN)  ✓ pagefind found$(RESET)" || echo "$(RED)  ✗ pagefind not found (install: make install-pagefind)$(RESET)"
	@command -v curl     >/dev/null 2>&1 && echo "$(GREEN)  ✓ curl found$(RESET)"     || echo "$(RED)  ✗ curl not found (needed by the fetch-*.sh scripts)$(RESET)"
	@command -v python3  >/dev/null 2>&1 && echo "$(GREEN)  ✓ python3 found$(RESET)"  || echo "$(RED)  ✗ python3 not found (needed by fetch-avatars.sh)$(RESET)"
	@command -v gh       >/dev/null 2>&1 && echo "$(GREEN)  ✓ gh found$(RESET)"       || echo "$(YELLOW)  ⊙ gh not found (optional, for make deploy)$(RESET)"
	@command -v aspell   >/dev/null 2>&1 && echo "$(GREEN)  ✓ aspell found$(RESET)"   || echo "$(YELLOW)  ⊙ aspell not found (optional, for spell-check)$(RESET)"
