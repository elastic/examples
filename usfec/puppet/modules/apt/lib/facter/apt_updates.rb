apt_package_updates = nil
Facter.add("apt_has_updates") do
  confine :osfamily => 'Debian'
  if File.executable?("/usr/lib/update-notifier/apt-check")
    apt_package_updates = Facter::Util::Resolution.exec('/usr/lib/update-notifier/apt-check 2>/dev/null').split(';')
  end

  setcode do
    apt_package_updates != ['0', '0'] unless apt_package_updates.nil?
  end
end

Facter.add("apt_package_updates") do
  confine :apt_has_updates => true
  setcode do
    packages = Facter::Util::Resolution.exec('/usr/lib/update-notifier/apt-check -p 2>/dev/null').split("\n")
    if Facter.version < '2.0.0'
      packages.join(',')
    else
      packages
    end
  end
end

Facter.add("apt_updates") do
  confine :apt_has_updates => true
  setcode do
    Integer(apt_package_updates[0])
  end
end

Facter.add("apt_security_updates") do
  confine :apt_has_updates => true
  setcode do
    Integer(apt_package_updates[1])
  end
end
