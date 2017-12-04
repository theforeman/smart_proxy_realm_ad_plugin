%global gem_name passgen

Name: rubygem-%{gem_name}
Version: 1.0.2
Release: 1%{?dist}
Summary: A password generation gem for Ruby and Rails applications
Group: Development/Languages
License: MIT
URL: http://github.com/cryptice/passgen
Source0: http://rubygems.org/gems/%{gem_name}-%{version}.gem
Requires: ruby(release)
Requires: ruby
Requires: ruby(rubygems) >= 1.2
BuildRequires: ruby(release)
BuildRequires: ruby
BuildRequires: rubygems-devel >= 1.2
BuildArch: noarch
Provides: rubygem(%{gem_name}) = %{version}

%description
A password generation gem for Ruby and Rails applications.


%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
gem unpack %{SOURCE0}

%setup -q -D -T -n  %{gem_name}-%{version}

gem spec %{SOURCE0} -l --ruby > %{gem_name}.gemspec

%build
# Create the gem as gem install only works on a gem file
gem build %{gem_name}.gemspec

# %%gem_install compiles any C extensions and installs the gem into ./%%gem_dir
# by default, so that we can move it into the buildroot in %%install
%gem_install

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/

%files
%dir %{gem_instdir}
%{gem_instdir}/Manifest
%{gem_instdir}/init.rb
%{gem_libdir}
%exclude %{gem_instdir}/passgen.gemspec
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/CHANGELOG
%doc %{gem_instdir}/README.rdoc
%{gem_instdir}/Rakefile
%{gem_instdir}/spec

%changelog
