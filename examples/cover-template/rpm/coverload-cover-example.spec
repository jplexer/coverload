Name:       coverload-cover-example
Version:    0.1.0
Release:    1
Summary:    Example cover for coverload
License:    MIT
BuildArch:  noarch
Source0:    %{name}-%{version}.tar.bz2
Requires:   coverload

%description
%{summary}.

%prep
%setup -q -n %{name}-%{version}

%build

%install
install -d %{buildroot}%{_datadir}/coverload/covers/example
install -m 644 cover.json Cover.qml %{buildroot}%{_datadir}/coverload/covers/example/

%files
%{_datadir}/coverload/covers/example
