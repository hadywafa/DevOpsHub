Nice. Let me check the current install method — spec-kit moves fast.The good news: spec-kit has an official air-gapped path, and it drops straight onto what you already built. Their guide notes that `specify init` needs no network access — bundled assets are used by default, so the usual blocker (init pulling templates from GitHub releases) doesn't apply.

Even better, you don't need to rebuild Python. Your `pybuild` image already has the exact interpreter — just layer on top of it.

Latest release is **v0.13.0** (Jul 17, 2026).

---

## PART A — On your laptop

**Step 1.** In the same `~/pybuild` folder, create a second file named `Dockerfile.specify`:

```dockerfile
FROM pybuild

ENV PY=/home/appadmin/python3.14/bin/python3

RUN dnf -y install git && dnf clean all

WORKDIR /speckit
RUN git clone --depth 1 --branch v0.13.0 https://github.com/github/spec-kit.git . \
 && $PY -m pip install build \
 && $PY -m build --wheel --outdir dist/ \
 && $PY -m pip download -d dist/ dist/specify_cli-*.whl \
 && tar -czf /specify-wheels.tar.gz -C /speckit dist
```

**Step 2.** Build and extract:

```bash
docker build --platform linux/amd64 -f Dockerfile.specify -t specifybuild .
docker create --name tmp2 specifybuild
docker cp tmp2:/specify-wheels.tar.gz .
docker rm tmp2
ls -lh specify-wheels.tar.gz
```

Should be a few MB. **Step 3.** Copy it to the offline server.

---

## PART B — On the offline server

```bash
cd ~
tar -xzf specify-wheels.tar.gz
pip install --no-index --find-links=./dist specify-cli
specify version
rm -rf ~/dist ~/specify-wheels.tar.gz
```

Then scaffold a project:

```bash
specify init my-project --integration copilot --ignore-agent-tools
cd my-project && ls -la
```

You should see `.specify/` with `templates/`, `scripts/bash/`, and `memory/`, plus the agent command files.

---

## Three things worth knowing

**Why `FROM pybuild` matters.** The guide warns that `pip download` resolves platform-specific wheels, so it must run on a machine with the same OS and Python version as the target. Building on top of your existing image guarantees that — same EL8, same CPython 3.14 ABI. Downloading these on your laptop would give you wheels that silently don't match.

**`--ignore-agent-tools` is deliberate.** `specify init` checks for an installed AI coding agent and will refuse otherwise. Your air-gapped box has none, and that's fine — spec-kit only *writes* the spec files and slash-command definitions. The agent that consumes them runs wherever you actually do the AI-assisted work. Common pattern: scaffold and commit on the server, then work against the repo from a machine that has Copilot or Claude Code.

**Check git.** `git --version` on the server — `specify init` runs `git init` by default. RHEL 8 usually ships it; if it's missing, add `--no-git`.

One caveat I'd flag rather than paper over: the README now says the PyPI `specify-cli` package is official, while the installation guide still carries a warning that packages named `specify-cli` on PyPI are not affiliated with the project. The docs contradict each other. Building the wheel from the tagged git repo, as above, sidesteps that entirely — you get the artifact straight from `github/spec-kit` at a pinned tag, which is what you want for an enterprise box anyway.