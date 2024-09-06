#!/usr/bin/env bash

sudo apt update
# ## handy stuff
sudo apt install --yes --no-install-recommends \
    htop \
    less \
    man \
    tree \
    vim
# ## install chrome dependencies (for decktape)
sudo apt install --yes  --no-install-recommends \
    libnss3 libdbus-1-3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libxkbcommon0 libasound2
sudo rm -rf /var/lib/apt/lists/*

# ## Install TinyTex
quarto install tinytex
# ## install packages
# tlmgr install pgf

# ## make mamba available
# shellcheck disable=SC2016
echo 'eval "$("${MAMBA_EXE}" shell hook --shell=bash)"' >> ~/.bashrc

# ## get env name
# ##  Note, this probably causes problems when there are several env files found!
env_file=".devcontainer/environment.dev.yml"
conda_env_name=$(sed -ne 's/^name: \(.*\)$/\1/p' ${env_file:?})
# ## install env
micromamba create --file "${env_file:?}" --yes

# ## activate env
eval "$("${MAMBA_EXE}" shell hook --shell=bash)"
micromamba activate "${conda_env_name:?}"

# ## clean python cache
micromamba clean --all --yes
python3 -m pip cache purge

# ## install npm packages
npm install -g \
    markdownlint-cli2 markdownlint-cli2-formatter-pretty markdownlint-cli2-formatter-summarize \
    decktape

# ## clean npm cache
npm cache clean --force
