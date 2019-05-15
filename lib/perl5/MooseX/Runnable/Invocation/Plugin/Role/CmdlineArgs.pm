package MooseX::Runnable::Invocation::Plugin::Role::CmdlineArgs;
BEGIN {
  $MooseX::Runnable::Invocation::Plugin::Role::CmdlineArgs::AUTHORITY = 'cpan:JROCKWAY';
}
$MooseX::Runnable::Invocation::Plugin::Role::CmdlineArgs::VERSION = '0.09';
use Moose::Role;
use namespace::autoclean;

requires '_build_initargs_from_cmdline';

1;
