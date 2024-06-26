# frozen_string_literal: true

Puppet::Type.newtype(:rabbitmq_erlang_cookie) do
  desc <<~DESC
    Type to manage the rabbitmq erlang cookie securely

    This is essentially a private type used by the rabbitmq::config class
    to manage the erlang cookie. It replaces the rabbitmq_erlang_cookie fact
    from earlier versions of this module. It manages the content of the cookie
    usually located at "${rabbitmq_home}/.erlang.cookie", which includes
    stopping the rabbitmq service and wiping out the database at
    "${rabbitmq_home}/mnesia" if the user agrees to it. We don't recommend using
    this type directly.
  DESC

  newparam(:path, namevar: true) do
    desc 'Path of the erlang cookie'
  end

  newproperty(:content) do
    desc 'Content of cookie'
    newvalues(%r{^\S+$})

    def change_to_s(_current, _desired)
      'The rabbitmq erlang cookie was changed'
    end

    def is_to_s(_value)
      '[old content redacted]'
    end

    def should_to_s(_value)
      '[new content redacted]'
    end
  end

  newparam(:force) do
    desc 'Force parameter'
    defaultto(:false)
    newvalues(:true, :false)
  end

  newparam(:rabbitmq_user) do
    desc 'Rabbitmq User'
    defaultto('rabbitmq')
  end

  newparam(:rabbitmq_group) do
    desc 'Rabbitmq Group'
    defaultto('rabbitmq')
  end

  newparam(:rabbitmq_home) do
    desc 'Path to the rabbitmq home directory'
    defaultto('/var/lib/rabbitmq')
  end

  newparam(:service_name) do
    desc 'Name of the service'
    newvalues(%r{^\S+$})
  end
end
