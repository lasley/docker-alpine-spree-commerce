FROM alpine:3.7

ARG RUN_USER=spree
ARG RUN_GROUP=spree

ENV PACKAGES_BUILD="build-base curl-dev ruby-dev" \
    PACKAGES_DEV="libffi-dev libxml2-dev libxslt-dev postgresql-dev tzdata yaml-dev zlib-dev" \
    PACKAGES_REQUIRED="imagemagick nodejs ruby ruby-io-console ruby-json yaml" \
    VERSION_RAILS="5.1.4" \
    VERSION_SPREE="3.3"

# Create user/group, install packages. Setup app directory. Install Spree + Assets.
RUN addgroup -S "${RUN_GROUP}" \
    && adduser -S -s /bin/false -G "${RUN_GROUP}" "${RUN_USER}" \
    && apk add --no-cache $PACKAGES_BUILD $PACKAGES_DEV $PACKAGES_REQUIRED \
    && mkdir -p /opt/spree/config /opt/spree/public \
    && chown -R "${RUN_USER}:${RUNGROUP}" /opt/spree \
    && gem install -N bundler \
    && gem install -N rails -v "${VERSION_RAILS}" \
    && gem install -N spree -v "${VERSION_SPREE}"

# Cleanup
RUN rm -rf /usr/lib/ruby/gems/*/cache/* \
    && apk del $PACKAGES_BUILD $PACKAGES_DEV

# Switch from root
USER "${RUN_USER}":"${RUN_GROUP}"

# Change to application directory and expose persistent storage
WORKDIR /opt/spree
VOLUME ["/opt/spree/config", "/opt/spree/public"]

# Entrypoint and expose service
COPY ./docker-entrypoint.sh /
COPY ./entrypoint.d/* /entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server"]

# Metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL maintainer="LasLabs Inc. <support@laslabs.com>" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Spree Commerce (Alpine)" \
      org.label-schema.description="Provides Spree Commerce based on Alpine Linux." \
      org.label-schema.url="https://laslabs.com/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/LasLabs/docker-alpine-spree-commerce" \
      org.label-schema.vendor="LasLabs Inc." \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
