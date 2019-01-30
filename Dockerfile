FROM node:carbon-slim

# Install AWS CLI
RUN apt-get update -q \
    && echo "Installing Python 3 & PIP & Git" \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends python3-pip python3-dev python3-setuptools git \
    && echo "Installing AWS CLI" \
    && pip3 install awscli \
    && rm -rf /var/lib/apt/lists/*

# Install and run keybase service
ENV KEYBASE_ALLOW_ROOT 1

RUN apt-get update -q \
    && curl -O https://prerelease.keybase.io/keybase_amd64.deb \
    && dpkg -i keybase_amd64.deb \
    # Ignore an error about missing `libappindicator1`
    # from the previous command, as the
    # subsequent command corrects it
    || $(exit 0) \
    && apt-get install --no-install-recommends -f -y \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && rm -f keybase_amd64.deb \
    && run_keybase

# Install docker 
RUN apt-get update -q \
    && apt-get install --no-install-recommends -y apt-transport-https ca-certificates \
        gnupg2 software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update -q \
    && apt-get install --no-install-recommends -y docker-ce \
    && rm -rf /var/lib/apt/lists/*

# Manages monorepo
RUN yarn global add lerna

# Print yarn version for peace of mind
RUN yarn --version

