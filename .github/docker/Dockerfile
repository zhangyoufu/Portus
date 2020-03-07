## Stage 0: provide source code
FROM opensuse/portus:head

## Stage 1: apply patch
FROM alpine
WORKDIR /portus
COPY portus.patch .
COPY --from=0 /srv/Portus/app/controllers/api/v2/tokens_controller.rb app/controllers/api/v2/tokens_controller.rb
COPY --from=0 /srv/Portus/app/controllers/auth/omniauth_callbacks_controller.rb app/controllers/auth/omniauth_callbacks_controller.rb
COPY --from=0 /srv/Portus/app/controllers/passwords_controller.rb app/controllers/passwords_controller.rb
COPY --from=0 /srv/Portus/app/models/namespace/auth_scope.rb app/models/namespace/auth_scope.rb
COPY --from=0 /srv/Portus/app/models/registry.rb app/models/registry.rb
COPY --from=0 /srv/Portus/app/models/tag.rb app/models/tag.rb
COPY --from=0 /srv/Portus/app/models/user.rb app/models/user.rb
COPY --from=0 /srv/Portus/app/views/shared/_header.html.slim app/views/shared/_header.html.slim
COPY --from=0 /srv/Portus/config/initializers/devise/oauth.rb config/initializers/devise/oauth.rb
COPY --from=0 /srv/Portus/lib/portus/http_helpers.rb lib/portus/http_helpers.rb
RUN patch -p1 <portus.patch

# workaround for https://github.com/SUSE/Portus/issues/2197
WORKDIR /bundler
COPY bundler-pr-6689.diff .
COPY --from=0 /srv/Portus/vendor/bundle/ruby/2.6.0/gems/bundler-1.16.4/lib/bundler/shared_helpers.rb shared_helpers.rb
RUN patch shared_helpers.rb bundler-pr-6689.diff

## Stage 2: final image
FROM opensuse/portus:head

# add Chaitin CA
COPY chaitin_ca.pem /etc/pki/trust/anchors/
RUN update-ca-certificates

# update-ca-certificates is not needed during runtime
RUN sed -i 's/^update-ca-certificates/#\0/' /init

# for some unknown reasons, cacert.pem of httpclient gem was lost in opensuse/portus:head image
RUN ln -s /var/lib/ca-certificates/ca-bundle.pem /cacert.pem && mv /cacert.pem /srv/Portus/vendor/bundle/ruby/*/gems/httpclient-*/lib/httpclient/

# add patched source code
COPY --from=1 /portus/app/controllers/api/v2/tokens_controller.rb /srv/Portus/app/controllers/api/v2/tokens_controller.rb
COPY --from=1 /portus/app/controllers/auth/omniauth_callbacks_controller.rb /srv/Portus/app/controllers/auth/omniauth_callbacks_controller.rb
COPY --from=1 /portus/app/controllers/passwords_controller.rb /srv/Portus/app/controllers/passwords_controller.rb
COPY --from=1 /portus/app/models/namespace/auth_scope.rb /srv/Portus/app/models/namespace/auth_scope.rb
COPY --from=1 /portus/app/models/registry.rb /srv/Portus/app/models/registry.rb
COPY --from=1 /portus/app/models/tag.rb /srv/Portus/app/models/tag.rb
COPY --from=1 /portus/app/models/user.rb /srv/Portus/app/models/user.rb
COPY --from=1 /portus/app/views/shared/_header.html.slim /srv/Portus/app/views/shared/_header.html.slim
COPY --from=1 /portus/config/initializers/devise/oauth.rb /srv/Portus/config/initializers/devise/oauth.rb
COPY --from=1 /portus/lib/portus/http_helpers.rb /srv/Portus/lib/portus/http_helpers.rb

# workaround for https://github.com/SUSE/Portus/issues/2197
COPY --from=1 /bundler/shared_helpers.rb /srv/Portus/vendor/bundle/ruby/2.6.0/gems/bundler-1.16.4/lib/bundler/shared_helpers.rb 

# fix PATH (for sanity)
ENV PATH /srv/Portus/bin:${PATH}
