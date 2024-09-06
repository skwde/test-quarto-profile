FROM buildpack-deps:bookworm

# ## set ARGS (possible to change during build time)
ARG MAMBA_VERSION=1.5.8
# ARG PYTHON_VERSION=3
ARG QUARTO_VERSION=1.5.57

# ## add non root user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --create-home $USERNAME --shell /bin/bash \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ## set ENV (persistent when container runs for resulting image)
ENV DEBIAN_FRONTEND=noninteractive
# ## set
# ##  LANG en_US.UTF-8
# ##  TZ
# ##  and install common packages
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV TZ="Europe/Zurich"
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=$LANG

# ## install / set up quart
# ##  https://github.com/quarto-dev/quarto-cli/blob/main/.github/actions/docker/action.yml#L47
RUN wget -O quarto-linux-amd64.deb "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && dpkg -i quarto-linux-amd64.deb \
    && rm quarto-linux-amd64.deb

# ## install mamba
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
ARG MAMBA_GROUP="conda"
# ## https://github.com/mamba-org/mamba/issues/1941
# ENV MAMBA_NO_LOW_SPEED_LIMIT=1
RUN curl -L "https://micro.mamba.pm/api/micromamba/linux-64/${MAMBA_VERSION}" | tar -xvj "bin/micromamba" \
    && micromamba config append --system channels conda-forge \
    && micromamba config append --system channels nodefaults \
    && micromamba config append --system pkgs_dirs ${MAMBA_ROOT_PREFIX}/pkgs \
    && micromamba config append --system envs_dirs ${MAMBA_ROOT_PREFIX}/envs \
    && mkdir -p ${MAMBA_ROOT_PREFIX} \
    && groupadd ${MAMBA_GROUP} \
    && chgrp -R ${MAMBA_GROUP} ${MAMBA_ROOT_PREFIX} \
    && chmod -R 770 ${MAMBA_ROOT_PREFIX} \
    && adduser ${USERNAME} ${MAMBA_GROUP}

# ## set default shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# RUN micromamba install --yes --name base \
#         "python=${PYTHON_VERSION}" \
#         "pip>=10" \
#         pre-commit \
#         nodejs \
#         && \
#     micromamba clean --all --yes && \
#     \
#     echo 'eval "$("${MAMBA_EXE}" shell hook --shell=bash)"' >> ~/.bashrc && \
#     echo "micromamba activate base" >> ~/.bashrc && \
#     source ~/.bashrc && \
#     \
#     npm install -g \
#         markdownlint-cli2 markdownlint-cli2-formatter-pretty markdownlint-cli2-formatter-summarize \
#         decktape \
#         && \
#     npm cache clean --force