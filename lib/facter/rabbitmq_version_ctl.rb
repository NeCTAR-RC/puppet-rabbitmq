Facter.add(:rabbitmq_version_ctl) do
    setcode do
      if Facter::Util::Resolution.which('rabbitmqctl')
        rabbitmq_version_ctl = Facter::Core::Execution.execute('rabbitmqctl version 2>&1')
        %r{^([\w\.]+)}.match(rabbitmq_version_ctl).to_a[1]
      end
    end
  end
