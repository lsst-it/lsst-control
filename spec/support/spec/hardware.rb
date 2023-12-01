# frozen_string_literal: true

shared_examples 'powertop' do
  it do
    case facts[:dmi]['manufacturer']
    when %r{Advantech}, %r{VersaLogic Corporation}
      is_expected.to contain_class('powertop').with_ensure('absent')
    else
      is_expected.to contain_class('powertop').with_ensure('present')
    end
  end
end
