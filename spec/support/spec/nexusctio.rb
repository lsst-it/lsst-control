# frozen_string_literal: true

shared_examples 'nexusctio' do
  it do
    is_expected.to contain_yumrepo('nexus-ctio').with(
      'baseurl' => 'http://cagvm3.ctio.noao.edu/nexus/repository/labview-rpm/rubin/',
      'gpgcheck' => false
    )
  end

  it do
    is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-MSO').with(
      ensure: 'file',
      mode: '0644',
      content: <<~GPG
          -----BEGIN PGP PUBLIC KEY BLOCK-----
        Version: GnuPG v2.0.22 (GNU/Linux)

        mQINBGC3zR8BEACw7AKpnTXmhvjHU5hfdBfbbdOx8azUtW3Oogr6zUcAMd0meTfj
        4msB71LePoMX6WskN9RckoIJvxlIjcVPlbCe7euBDLiQL1KhuQXWK5veYIlsBYMx
        agL8CA/rHEk1yfvuk9pxS7CqziRQ4laxJPnYbrOaRZevYlumyusDfGQ17x3EbM1D
        N3UYvnzhla0lq/YmGSLVNgmqMV8PJSzv+iQku5MbI4ahxSCnVedOvepXdcePQPwf
        /IZc/4IwquKjTNXCs+WhlMbM7T/0M1WeYm7h52UwUOlWB2pgN1ryW+iSbLCu0rBd
        XJtPw4iERbhKpZmkmZJ6vrpCA+E2OFW2LIFve0N5mAUY0JkliFE34kG+FY6ZtD7z
        vlF4U0AxzAOvo4zoIJcxRHjt7u4UsOIpMbBvm+B1rtbX3ZGGiZecpFhe5GONrh++
        jvT4kcpKjADY4rSq583iDZ/mWF+XUozyTmqbuHxFVTjAKCNvQE0WyL9+5g9zCH1a
        7AtIOSrfVP5YBHfLMiPOXpep8Pf7CaNAbSQb5JxFABYSRsLM6v2+Y3zm61dSIfeU
        ZTRIFAsWG0Db5VdtdznBZnZRa5Avs6AUN9KOiVWi/D1KofZeeHU6DSfW+4Wq8vr4
        Ekm8YUfQuPP6Fvre5qvytBf17MGg0vKZ7Z/ipdhs2StxFnoO+3yK2BfoKwARAQAB
        tF9HUEcgTVNPIChHUEcgTVNPIHNpZ25hdHVyZSBmb3Igc3RhYmxlIHJwbSBmaWxl
        cyBpbiBOZXh1czMgcmVwb3NpdG9yeSkgPGRpZWdvLmdvbWV6QG5vaXJsYWIuZWR1
        PokCOQQTAQIAIwUCYLfNHwIbAwcLCQgHAwIBBhUIAgkKCwQWAgMBAh4BAheAAAoJ
        EM5tAOEzBhcslQgP/2uGa/PZwVSo9/PHvnr7sD6/QT4hM0/Z2ngCGo0xOTTLm89C
        K0DxkU21L9m2/BUZPJp4krB5p5GOUjiRdpouiPElnULBaBB8eZIVQWK3ifenqVq6
        FqxNqFDBKcKQ9ZVgvz88GYHLDSYTvv2QtTozCVhjcSWCPorYRuLbliOc4k7jqmjk
        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
        eO+RKR5uzsEbWmMvQkTP
        =vYiw
        -----END PGP PUBLIC KEY BLOCK-----
      GPG
    )
  end
end
