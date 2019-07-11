FROM oraclelinux:7-slim
COPY olcne_rpm_list.md olcne_rpm_list.md
COPY *.rpm /
RUN for rpm in `cat olcne_rpm_list.md`; do \
       yum install -y ${rpm}; \
       if [[ $? -ne 0 ]]; then exit 1; fi \
    done; \
    yum clean all; rm -rf /var/cache/yum/*; rm -f *.rpm olcne_rpm_list.md
RUN test -d /LICENSES || ln -s /usr/share/licenses /LICENSES
