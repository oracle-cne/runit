%global _buildhost      build-ol%{?oraclelinux}-%{?_arch}.oracle.com

Name:                   runit
Version:                2.1.2
Release:                5%{?dist}
Summary:                A UNIX init scheme with service supervision
License:                BSD
Group:                  System/Base
Url:                    http://smarden.org/runit/
Source:                 %{name}-%{version}.tar.bz2
Vendor:                 Oracle America

BuildRequires:          git
BuildRequires:          make
BuildRequires:          gcc
BuildRequires:          glibc-static
Requires:               which

%global debug_package   %{nil}

%description
runit is a cross-platform Unix init scheme with service supervision; a
replacement for sysvinit and other init schemes. It runs on GNU/Linux, *BSD,
Mac OS X, and Solaris, and can easily be adapted to other Unix operating
systems. runit implements a simple three-stage concept. Stage 1 performs the
system's one-time initialization tasks. Stage 2 starts the system's uptime
services (via the runsvdir program). Stage 3 handles the tasks necessary to
shutdown and halt or reboot.

%prep
%setup -n %{name}-%{version}

%build
sh package/compile

%install
for i in $(< package/commands) ; do
    %{__install} -D -m 0755 command/$i %{buildroot}%{_sbindir}/$i
done
for i in man/*8 ; do
    %{__install} -D -m 0755 $i %{buildroot}%{_mandir}/man8/${i##man/}
done
%{__install} -d -m 0755 %{buildroot}/etc/service
%{__install} -D -m 0750 etc/2 %{buildroot}%{_sbindir}/runsvdir-start

%files
%license package/COPYING THIRD_PARTY_LICENSES.txt
%defattr(-,root,root,-)
%{_sbindir}/chpst
%{_sbindir}/runit
%{_sbindir}/runit-init
%{_sbindir}/runsv
%{_sbindir}/runsvchdir
%{_sbindir}/runsvdir
%{_sbindir}/sv
%{_sbindir}/svlogd
%{_sbindir}/utmpset
%{_sbindir}/runsvdir-start
%{_mandir}/man8/*.8*
%doc doc/* etc/
%doc package/CHANGES package/COPYING package/README package/THANKS package/TODO
%dir /etc/service

%clean
rm -fr %{buildroot}
rm -fr %{_builddir}/%{name}-%{version}


%changelog
* Fri Aug 21 2026 Daniel Krasinski <daniel.krasinski@oracle.com> - 2.1.2-5
- Add OL9 support

* Tue Oct 10 2023 Murali Annamneni <murali.annamneni@oracle.com> - 2.1.2-4
- Add aarch64 build support

* Wed Feb 22 2023 Michael Thompson <michael.a.thompson@oracle.com> 2.1.2-3
- Add OL8 support

* Mon Jul 01 2019 Durai Govindasamy <durai.vattakalvalasu.govindas@oracle.com> 2.1.2-1.0.2
- added rpm spec file for container image

* Tue May 28 2019 Durai Govindasamy <durai.vattakalvalasu.govindas@oracle.com> 2.1.2-1.0.1
- Initial packaging
