# TODO:
# Do not run locally, only Travis should submit to scrutinizer. Just testing this out for the time being.

require 'scrutinizer/ocular'
Scrutinizer::Ocular.enabled = true
Scrutinizer::Ocular.watch! 'rails'