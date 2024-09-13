# frozen_string_literal: true

shared_examples 'sssd services' do
  it do
    is_expected.to contain_class('sssd').with_service_names(['sssd'])
                                        .that_requires('Class[ipa]')
  end

  it do
    is_expected.to contain_service('sssd').with(
      ensure: 'running',
      enable: true
    )
  end

  %w[
    sssd-autofs
    sssd-autofs.socket
    sssd-kcm
    sssd-kcm.socket
    sssd-nss
    sssd-nss.socket
    sssd-pac
    sssd-pac.socket
    sssd-pam
    sssd-pam-priv.socket
    sssd-pam.socket
    sssd-ssh
    sssd-ssh.socket
    sssd-sudo
    sssd-sudo.socket
  ].each do |unit|
    it do
      is_expected.to contain_service(unit).with(
        ensure: 'stopped',
        enable: false
      )
                                          .that_requires('Class[sssd]')
                                          .that_requires('Class[ipa]')
    end
  end
end
