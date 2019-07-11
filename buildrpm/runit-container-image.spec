%if 0%{?with_debug}
# https://bugzilla.redhat.com/show_bug.cgi?id=995136#c12
%global _dwz_low_mem_die_limit 0
%else
%global debug_package   %{nil}
%endif

%global app_name runit
%global app_version 2.1.2
%global oracle_release_version 1.0.2
%global app_container_name runit
%global app_container_version %{app_version}

Name:           %{app_name}-container-image
Version:        %{app_version}
Release:        %{oracle_release_version}%{?dist}
BuildArch:      x86_64
Summary:        A UNIX init scheme with service supervision
License:        BSD
Group:          System/Base
Url:            http://smarden.org/runit/
Source:         %{name}-%{version}.tar.bz2
Vendor:	        Oracle America

%description
runit is a cross-platform Unix init scheme with service supervision; a
replacement for sysvinit and other init schemes. It runs on GNU/Linux, *BSD,
Mac OS X, and Solaris, and can easily be adapted to other Unix operating
systems. runit implements a simple three-stage concept. Stage 1 performs the
system's one-time initialization tasks. Stage 2 starts the system's uptime
services (via the runsvdir program). Stage 3 handles the tasks necessary to
shutdown and halt or reboot.

%prep
%setup -q -n %{name}-%{version}

%build
./olm/builds/docker-images.sh \
  --app-name %{app_name} \
  --app-version %{version} \
  --oracle-release-version %{oracle_release_version} \
  --app-container-name %{app_container_name} \
  --app-container-version %{app_container_version} \
  --yum-package-list %{app_name}-%{version}-%{oracle_release_version}.el7

%install
install -m 755 -d %{buildroot}/usr/local/share/olcne
install -p -m 755 -t %{buildroot}/usr/local/share/olcne oracle_docker/%{app_name}.tar

%files
%license package/COPYING
/usr/local/share/olcne/%{app_name}.tar

%changelog
* Mon Jul 01 2019 Durai Govindasamy <durai.vattakalvalasu.govindas@oracle.com> 2.1.2-1.0.2
- added rpm spec file for container image

* Fri May 10 2019 Durai Govindasamy <durai.vattakalvalasu.govindas@oracle.com> 0.18.0-1.0.1
- Initial packaging