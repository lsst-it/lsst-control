# frozen_string_literal: true

require 'spec_helper'

def coreutils_sort(data)
  pat = %r{[\W_]} # chars coreutils sort seems to ignore
  data.sort do |a, b|
    ax = a.gsub(pat, '')
    bx = b.gsub(pat, '')

    (ax == bx) ? b.size <=> a.size : ax <=> bx
  end
end

describe 'Puppetfile' do
  subject(:puppetfile) { File.read(puppetfile_path) }

  it 'mod lines are sorted' do
    # ignore lines which aren't declaring a module
    mods = puppetfile.split("\n").grep(%r{^\s*mod})

    # convert arrays into strings so rspec will produce a diff with useful context
    expect(mods.join("\n")).to eq coreutils_sort(mods).join("\n")
  end

  it 'mod names use slash instead of dash as namespace separator' do
    # ignore lines which aren't declaring a module
    mods = puppetfile.split("\n").grep(%r{^\s*mod})

    names = mods.map { |l| l.split[1] }

    names.each { |n| expect(n).not_to match('-') }
  end
end
