FROM java:8-re

# setup useful environment variables
ENV STASH_HOME     /var/local/atlassian/stash
ENV STASH_INSTALL  /usr/local/atlassian/stash
ENV STASH_VERSION  3.2.0

# install ``Atlassian Stash`` and dependencies
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 git-core xmlstarlet \
    && apt-get clean \
    && mkdir --parents      "${STASH_HOME}" \
    && chown nobody:nogroup "${STASH_HOME}" \
    && mkdir --parents      "${STASH_INSTALL}" \
    && curl -Ls             "http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-${STASH_VERSION}.tar.gz" | tar -zx --directory  "${STASH_INSTALL}" --strip-components=1 \
    && chmod -R 777         "${STASH_INSTALL}/temp" \
    && chmod -R 777         "${STASH_INSTALL}/logs" \
    && chmod -R 777         "${STASH_INSTALL}/work" \
    && mkdir                "${STASH_INSTALL}/conf/Catalina" \
    && chmod -R 777         "${STASH_INSTALL}/conf/Catalina" \
    && mkdir                "${STASH_HOME}/lib" \
    && ln --symbolic        "/usr/lib/x86_64-linux-gnu/libtcnative-1.so" "${STASH_INSTALL}/lib/native/libtcnative-1.so" \
    && xmlstarlet           ed --inplace \
        --delete            "Server/Service/Engine/Host/@xmlValidation" \
        --delete            "Server/Service/Engine/Host/@xmlNamespaceAware" \
                            "${STASH_INSTALL}/conf/server.xml"

# run ``Atlassian Stash`` as unprivileged user by default
USER nobody:nogroup

# expose default ``Atlassian Stash`` HTTP and SSH port
EXPOSE 7990 7999

# set volume mount points for installation and home directory
VOLUME ["/usr/local/atlassian/stash", "/var/local/atlassian/stash"]

# run ``Atlassian Stash`` as a foreground process by default
ENTRYPOINT ["/usr/local/atlassian/stash/bin/start-stash.sh", "-fg"]
