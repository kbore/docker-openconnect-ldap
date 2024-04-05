FROM debian:11.9

LABEL maintainer="@kyon" \
      maintainer="kyon@kbore.com" \
      version=0.1 \
      description="Openconnect server with libpam-ldap for AD authentication"

# Forked from MarkusMcNugen for AD Auth
# Forked from TommyLau for unRAID

VOLUME /config

# Install ocserv
#RUN apk add --update bash rsync ipcalc sipcalc ca-certificates rsyslog logrotate runit

# 替换镜像源地址, 加快docker构建速度
COPY debian/sources.list /etc/apt/
# RUN rm /etc/apt/sources.list.d/debian.sources
RUN apt-get update && apt-get install -y ocserv libnss-ldap iptables procps rsync sipcalc ca-certificates

# 安装网络调试工具
RUN apt-get install -y vim net-tools iproute2
RUN rm -rf /etc/pam_ldap.conf && touch /config/pam_ldap.conf && ln -s /config/pam_ldap.conf /etc/pam_ldap.conf

# 解决vim操作习惯问题
RUN echo 'source $VIMRUNTIME/defaults.vim' >> /etc/vim/vimrc.local
RUN echo 'let skip_defaults_vim = 1' >> /etc/vim/vimrc.local
RUN echo 'set mouse=r' >> /etc/vim/vimrc.local
RUN echo 'set paste' >> /etc/vim/vimrc.local

ADD ocserv /etc/default/ocserv
ADD pam_ldap /etc/default/pam_ldap

WORKDIR /config

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 443/tcp
EXPOSE 443/udp
CMD ["ocserv", "-c", "/config/ocserv.conf", "-f", "-d2"]
#CMD ["/bin/bash"]