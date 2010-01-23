package User;

use 5.006;
use strict;
use warnings;
use Mysql;
use BotDB qw(userload);

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use User ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
    Load_Users Get_Permissions List_Users
    ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '0.01';

# Preloaded methods go here.

my %nick_index;

sub new {
    my ($nick, $mask, $perm, $chan) = @_;
    my $bot_user;
    $bot_user  = [$nick, $mask, $perm, $chan];
    push(@{$nick_index {$nick}}, $bot_user);
    bless $bot_user, 'User';
}

sub Get_Permissions {
    my ($package, $nick, $mask, $chan) = @_;
    my $bot_user;

    foreach $bot_user (@{$nick_index{$nick}}) {
        if (( lc($nick) eq lc($bot_user->[0]) )) {
            my ($file_ident, $file_host ) = split "@", $bot_user->[1];
            my ($user_ident, $user_host) = split "@", $mask;

            my $file_chan = $bot_user->[3];
            my $user_chan = $chan;


            if (( ! $file_ident ) or ( ! $file_host ) or ( ! $file_chan ) ) {
                return 0;
            }

            if ( $file_ident =~ /[^A-Za-z0-9-_.\*]/ ) {
                return 0;
            }

            if ( $file_host =~ /[^A-Za-z0-9-_.\*]/ ) {
                return 0;
            }

            if ( $file_chan =~ /[^#A-Za-z0-9-_.\*]/ ) {
                return 0;
            }

            my $count = ($file_host =~ tr/A-Za-z0-9\-\_\.//);

            if ( $count > 63 ) {
                return 0;
            }

            $file_ident = parse_string($file_ident);
            $file_host  = parse_string($file_host);
            $file_chan  = parse_string($file_chan);
            $user_chan  = parse_string($user_chan);

            return $bot_user->[2] if (( $user_ident =~ /$file_ident/ ) && ( $user_host =~ /$file_host/ ) && ( $user_chan =~ /^${file_chan}$/ ));
        }
    }

    return 0;

}

sub List_Users {
    my ($package, $chan) = @_;
    my ($bot_user, $bot_nick, $entry, @rlist);

    foreach $bot_nick (keys %nick_index) {
        foreach $bot_user (@{$nick_index{$bot_nick}}) {
            if ( (lc($chan) eq lc($bot_user->[3])) || ($bot_user->[3] eq "#*") ) {
                $entry = sprintf("%6d %s!%s", $bot_user->[2], $bot_user->[0], $bot_user->[1]);
                push (@rlist, $entry);
            }
        }
    }
    return @rlist;
}

sub Load_Users {
    my ($package, $config) = @_;

    # Load global users from file first
    open (CONFIG, "< $config") or die "can't open $config: $!\n";
    undef %nick_index;
    my $line;
    while ($line = <CONFIG>) {
        next if ($line =~ /^#/);
        chomp $line;
        my ($nick, $mask, $perm) = split ":", $line;
        &new($nick, $mask, $perm, '#*');
    }
    close(CONFIG);

    # Load local users from mysql second
    my @dbusers = BotDB->userload();
    foreach $line (@dbusers) {
        my ($nick, $mask, $perm, $chan) = split ":", $line;
        &new($nick, $mask, $perm, $chan);
    }

}

sub parse_string {
    my ($var) = @_;
    my @word;
    while ($var =~ /(.)/g) {
        my $char = $1;
        $char = "\.\*" if ( $char eq "\*");
        push (@word, $char);
    }
    my $newstring = join "", @word; 
    return "$newstring";
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

User - Perl extension for perlbot

=head1 SYNOPSIS

  use User;
  User->Load_Users(config_file);
  User->Get_Permissions(nick, mask);

=head1 DESCRIPTION

This module is intended to aid the perlbot script on it's loading and check of user permissions.
=head2 EXPORT

Load_Users
Get_Permissions

=head1 AUTHOR

Alvaro Toledo, E<lt>atoledo@keldon.orgE<gt>

=head1 SEE ALSO

L<perl>.

=cut
