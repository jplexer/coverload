Name:       coverload
Version:    1.0.0
Release:    1
Summary:    Custom app switcher covers
License:    MIT
BuildArch:  noarch
URL:        https://github.com/jplexer/coverload
Source0:    %{name}-%{version}.tar.bz2
Requires:   patchmanager >= 3.0
Requires:   lipstick-jolla-home-qt5

%define patchdir %{_datadir}/patchmanager/patches/%{name}

%description
A Patchmanager patch that lets the app switcher show custom covers for any
app. Other covers can be installed into %{_datadir}/coverload/covers.

%prep
%setup -q -n %{name}-%{version}

%build

%install
install -d %{buildroot}%{patchdir}
cp -r patch/* %{buildroot}%{patchdir}/
install -d %{buildroot}%{_datadir}/coverload/covers

%pre
if [ -d /tmp/patchmanager3/patches/%{name} ]; then
    /usr/sbin/patchmanager -u %{name} || true
fi

%post
# The daemon only rescans its patch list when an entry in patches/ is created
# or deleted, which can happen before unified_diff.patch has been unpacked.
# Restart it so it sees the complete patch.
systemctl try-restart dbus-org.SfietKonstantin.patchmanager.service || :

%preun
if [ -d /tmp/patchmanager3/patches/%{name} ]; then
    /usr/sbin/patchmanager -u %{name} || true
fi

%files
%{patchdir}
%dir %{_datadir}/coverload
%dir %{_datadir}/coverload/covers
