# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'lookup_in_parameter' do
  let(:msg) { 'lookup used to set the default value of a parameter' }

  context 'with fix disabled' do
    context 'no lookup in a parameter' do
      let(:code) do
        <<CODE
class acme (
  Stdlib::Absolutepath $config_dir,
) {
  file { $config_dir:
    ensure => directory,
  }

  file { "${config_dir}/modules":
    ensure => directory,
  }
}

define acme::module (
  String[1] $config,
) {
  include acme

  file { "${acmd::config_dir}/modules/${title}":
    ensure  => file,
    content => $config,
  }
}
CODE
      end

      it 'does not detect any problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'with lookup in a parameter' do
      let(:code) do
        <<CODE
        class acme (
  Stdlib::Absolutepath $config_dir,
) {
  file { $config_dir:
    ensure => directory,
  }

  file { "${config_dir}/modules":
    ensure => directory,
  }
}

define acme::module (
  String[1] $config,
  Stdlib::Absolutepath $config_dir = lookup('acme::config_dir'),
) {
  file { "${config_dir}/modules/${title}":
    ensure  => file,
    content => $config,
  }
}
CODE
      end

      it 'has 1 problem' do
        expect(problems).to have(1).problem
      end

      it 'creates a warning' do
        expect(problems).to contain_warning(msg).on_line(15).in_column(38)
      end
    end
  end
end
