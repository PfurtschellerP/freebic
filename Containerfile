# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /


# Base Image
FROM quay.io/fedora-ostree-desktops/silverblue:43

### [IM]MUTABLE /opt
RUN rm /opt && mkdir /opt

### MODIFICATIONS
COPY system_files/ /
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    /ctx/ca_certs.sh && \
    /ctx/himmelblau.sh && \
    /ctx/cleanup.sh

### LINTING
RUN bootc container lint
