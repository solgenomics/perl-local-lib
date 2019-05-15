package MooseX::Runnable::Invocation::Role::WithParsedArgs;
BEGIN {
  $MooseX::Runnable::Invocation::Role::WithParsedArgs::AUTHORITY = 'cpan:JROCKWAY';
}
$MooseX::Runnable::Invocation::Role::WithParsedArgs::VERSION = '0.09';
use Moose::Role;
use MooseX::Runnable::Util::ArgParser;
use namespace::autoclean;

has 'parsed_args' => (
    is       => 'ro',
    isa      => 'MooseX::Runnable::Util::ArgParser',
    required => 1,
);

1;
