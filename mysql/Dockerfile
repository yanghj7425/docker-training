#
# MAINTAINER:     H.J.Yang <tcby2yhj@gmail.com>
# docker_version:        18.06.1-ce
#
# dockering centos7
#
FROM mcentos:0.0.1
MAINTAINER H.J.Yang <tcdby2yhj@gmail.com>

COPY scripts /scripts
RUN  chmod +x /scripts/auto_install_mysql.sh
RUN ./scripts/auto_install_mysql.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]


