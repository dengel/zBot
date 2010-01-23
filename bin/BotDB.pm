package BotDB;

use 5.006;
use strict;
use warnings;
use Mysql;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    getnext learn replace append whoset getcnt getdate getlock gethits getid
    botquery botnumquery botrandquery lock unlock delete find list xtop xlast 
    addchan delchan useradd userdel userload link getlink addurl geturl
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	getnext learn replace append whoset getcnt getdate getlock gethits getid
    botquery botnumquery botrandquery lock unlock delete find list xtop xlast 
    addchan delchan useradd userdel userload link getlink addurl geturl
);
our $VERSION = '0.02';


# Preloaded methods go here.
my $config = require "db.conf";

# Informacion para la DB         
my $dbhost=$config->{dbhost};
my $dbname=$config->{dbname};
my $dbuser=$config->{dbuser};
my $dbpass=$config->{dbpass};


sub learn {
    my ($package, $nick, $mask, $chan, $value, @meaning) = @_;
    #my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $meaning = join " ", @meaning;
    return if ( ! $chan );
    $chan =~ s/^#//g;
    $value = parse($value);
    $meaning = parse($meaning);
    if (( $value ) and ( $meaning )) {
        my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
        my $sth1 = $db->query("insert into `canal_$chan` \(value, meaning, author, date\) values \('$value', '$meaning', '$nick!$mask', now()\);");
        if ( $sth1 ) {
            $value =~ s/\\//g;
            $meaning =~ s/\\//g;
            return ("$meaning");
        } else {
            return ("Termino ya definido");
        }
    }
    return;
}

sub replace {
    my ($package, $nick, $chan, $value, $arg1, $arg2) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $value  = parse($value);
    $chan  =~ s/^#//g;

    my $sth1 = $db->query("select meaning from `canal_$chan` where value = '$value';");
    my $meaning = $sth1->fetchrow;

    if ( $meaning ) {
        $meaning =~ s/$arg1/$arg2/g;
        my $sth2 = $db->query("update `canal_$chan` set meaning='$meaning', date=now() where value='$value';");
        return ("$meaning");
    } else {
        return ("<no definido>");
    }
}

sub rename {
    my ($package, $nick, $chan, $value, $nvalue) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $value  = parse($value);
    $nvalue  = parse($nvalue);
    $chan  =~ s/^#//g;

    my $sth1 = $db->query("select value from `canal_$chan` where value = '$value';");
    my $sval = $sth1->fetchrow;

    my $sth2 = $db->query("select value from `canal_$chan` where value = '$nvalue';");
    my $dval = $sth2->fetchrow;

    if ( $sval ) {
        if ($dval) {
            return ("Termino $nvalue ya existe");
        } else {
            my $sth3 = $db->query("update `canal_$chan` set value='$nvalue' where value='$value';");
            return ("$value redefinido como $nvalue");
        }
    } else {
        return ("Termino $value no existe.");
    }
}

sub append {
    my ($package, $nick, $mask, $chan, $value, @meaning) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $meaning = join " ", @meaning;
    return if ( ! $chan );
    $chan =~ s/^#//g;
    $value = parse($value);
    $meaning = parse($meaning);
    if (( $value ) and ( $meaning )) {
        my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
        my $sth1 = $db->query("update `canal_$chan` set meaning=concat\(meaning,' $meaning'\), date=now() where value='$value';");
        if ( $sth1 ) {
            $value =~ s/\\//g;
            $meaning =~ s/\\//g;
            return ("$meaning");
        } else {
            return ("Termino no definido");
        }
    }
    return;
}

sub delete {
    my ($package, $chan, $value) = @_;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    if ( $value ) {
        my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
        my $sth1 = $db->query("delete from `canal_$chan` where value = '$value';");
    }
}

sub lock {
    my ($package, $chan, $value) = @_;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    if ( $value ) {
        my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
        my $sth1 = $db->query("update `canal_$chan` set locked='1' where value='$value';");
    }
}

sub unlock {
    my ($package, $chan, $value) = @_;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    if ( $value ) {
        my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
        my $sth1 = $db->query("update `canal_$chan` set locked='0' where value='$value';");
    }
}

sub whoset {
    my ($package, $nick, $chan, $text) = @_;
    $text  = parse($text);
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select author from `canal_$chan` where value = '$text';");
    my $who = $sth1->fetchrow;

    if ( $who ) {
        return ("$who");
    }
}

sub getcnt {
    my ($package, $nick, $chan, $text) = @_;
    my $sth1;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");

    if ($text) {
        $text =~ s/'//g;
        $sth1 = $db->query("select count(*) from `canal_$chan` where author like '$text!%'");
    } else {
        $sth1 = $db->query("select count(*) from `canal_$chan`");
    }

    my $who = $sth1->fetchrow;

    if ( $who ) {
        return ("$who");
    }
}

sub getdate {
    my ($package, $nick, $chan, $text) = @_;
    $text  = parse($text);
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select date from `canal_$chan` where value = '$text';");
    my $who = $sth1->fetchrow;

    if ( $who ) {
        return ("$who");
    }
}


sub getid {
    my ($package, $chan, $text) = @_;
    $text  = parse($text);
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select id from `canal_$chan` where value = '$text';");
    my $who = $sth1->fetchrow;

    if ( $who ) {
        return ("$who");
    }
}

sub gethits {
    my ($package, $chan, $text) = @_;
    $text  = parse($text);
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select hits from `canal_$chan` where value = '$text';");
    my $who = $sth1->fetchrow;

    if ( $who ) {
        return ("$who");
    }
}

sub getlock {
    my ($package, $chan, $text) = @_;
    $text  = parse($text);
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select locked from `canal_$chan` where value = '$text';");
    my $who = $sth1->fetchrow;

    return ($who);
}

sub getlink {
    my ($package, $chan, $text) = @_;
    $text  = parse($text);
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select cx2.value from `canal_$chan` AS cx1, `canal_$chan` AS cx2 where cx1.value='$text' AND cx1.link=cx2.id");
    my $who = $sth1->fetchrow;

    return ($who);
}

sub addurl {
    my ($package, $chan, $nick, $url) = @_;
    $url  = parse($url);
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("insert into urls \(nick, channel, url\) values \('$nick', '$chan', '$url'\);");

    return;
}

sub geturl {
    my ($package, $chan, $arg) = @_;
    my $clause="";
    if ($arg) {
        $clause = "AND nick='$arg'";
    }
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select url from urls where channel='$chan' $clause order by u_id desc limit 1;");
    my $url = $sth1->fetchrow;
    if (! $url) {
        $url="http://127.0.0.1/";
    }
    return ("$url");
}

sub list {
    my ($package, $chan, $value) = @_;
    $value = parse($value);
    $value =~ s/\*/%/g;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select value from `canal_$chan` where value like '$value';");
    my @list;
    my $temp;
    while ( $temp = $sth1->fetchrow ) {
        push (@list, $temp);
    }

    my $count = @list;
    if ( @list ) {
        my $list = join " ", @list;
        return ("$list");
    } else {
        return ("No existen concordancias");
    }
}

sub xtop {
    my ($package, $chan, $limit) = @_;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select value from `canal_$chan` order by hits desc limit $limit;");
    my @list;
    my $temp;
    while ( $temp = $sth1->fetchrow ) {
        push (@list, $temp);
    }

    my $count = @list;
    if ( @list ) {
        my $list = join " ", @list;
        return ("$list");
    } else {
        return ("No existen concordancias");
    }
}

sub xlast {
    my ($package, $chan, $limit) = @_;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select value from `canal_$chan` order by id desc limit $limit;");
    my @list;
    my $temp;
    while ( $temp = $sth1->fetchrow ) {
        push (@list, $temp);
    }

    my $count = @list;
    if ( @list ) {
        my $list = join " ", @list;
        return ("$list");
    } else {
        return ("No existen concordancias");
    }
}

sub find {
    my ($package, $chan, $value) = @_;
    $value = parse($value);
    $value =~ s/\*/%/g;
    $chan =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    # Need a better way to prevent a flood here... limit sux
    my $sth1 = $db->query("select value from `canal_$chan` where meaning like '%$value%' limit 75;");
    my @list;
    my $temp;
    while ( $temp = $sth1->fetchrow ) {
        push (@list, $temp);
    }

    my $count = @list;
    if ( @list ) {
        my $list = join " ", @list;
        return ("$list");
    } else {
        return ("No existen concordancias");
    }
}

sub addchan {
    my ($package, $chan) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $chan =~ s/^#//g;
    my $sth1 = $db->query("create table `canal_$chan` \(id int\(11\) NOT NULL auto_increment,value varchar\(255\) unique not null, meaning text not null, author varchar\(80\) not null, locked int(1) not null default '0', date date not null default '0000-00-00', hits int(11) not null default '0', link int(11), PRIMARY KEY \(id\)\);");
    if ( $sth1 ) {
        my $sth2 = $db->query("insert into canales \(nombre\) values \('$chan'\);");
        return 0;
    } else {
        return 1;
    }
}

sub delchan {
    my ($package, $chan) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $chan =~ s/^#//g;
    my $sth1 = $db->query("drop table `canal_$chan`;");
    if ( $sth1 ) {
        my $sth2 = $db->query("delete from canales where nombre='$chan';");
        return 0;
    } else {
        return 1;
    }
}

sub joinchan {
    my ($package, $chan) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $chan =~ s/^#//g;
    my $check = $db->query("describe `canal_$chan`");
    if ( $check ) {
        my $sth1 = $db->query("insert into canales \(nombre\) values \('$chan'\);");
        return 0;
    } else {
        return 1;
    }
}

sub leavechan {
    my ($package, $chan) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $chan =~ s/^#//g;
    my $check = $db->query("describe `canal_$chan`");
    if ( $check ) {
        my $sth1 = $db->query("delete from canales where nombre = '$chan';");
        return 0;
    } else {
        return 1;
    }  
}

sub listchans {
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select nombre from canales;");
    my $temp;
    my @chans;
    while ( $temp = $sth1->fetchrow ) {
        $temp =~ s/^/#/g;
        push (@chans, $temp);
    }
    return (@chans);
}

sub useradd {
    my ($package, $chan, $mask, $level, $rlevel) = @_;

    return "No puedes asignar un nivel mayor o igual que el tuyo ($rlevel <= $level)" if ($level >= $rlevel);

    my ($nmask, $rest, $host, $nick, $user);
    ($nick, $nmask) = split (/\!/, $mask);
    ($user, $host) = split (/\@/, $nmask);
    return "Mask malformado. Debe ser nick!ident\@host" if ( (! $nick) || (! $user) || (! $host) );

    my $nchan  = $chan;
    $nchan  =~ s/^#//g;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select * from canales where nombre='$nchan';");
    if ( $sth1->rows ) {
        my $sth2 = $db->query("select uid from users where nick='$nick' and mask='$nmask' and channel='$chan';");
        if ( $sth2->rows ) {
            my $result = $sth2->fetchrow;
            my $sth3 = $db->query("update users set level='$level' where uid='$result';");
            if ( $sth3 ) {
                return "Acceso de $mask cambiado a $level en canal $chan";
            } else {
                return "Error al tratar de cambiar el nivel del usuario";
            }
        } else {
            my $sth4 = $db->query("insert into users \(nick, mask, level, channel\) values \('$nick', '$nmask', '$level', '$chan'\);");
            if ( $sth4 ) {
                return "Usuario $mask agregado al canal $chan con nivel $level";
            } else {
                return "Error al tratar de agregar el usuario";
            }
        }
    } else {
        return "Canal $chan no existe";
    }
}

sub userdel {
    my ($package, $chan, $mask, $rlevel) = @_;

    my ($nmask, $rest, $host, $nick, $user);
    ($nick, $nmask) = split (/\!/, $mask);
    ($user, $host)  = split (/\@/, $nmask) if ($nmask) ;
    return "Mask malformado. Debe ser nick!ident\@host" if ( (! $nick) || (! $user) || (! $host) );

    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select uid,level from users where nick='$nick' and mask='$nmask' and channel='$chan';");
    if ( $sth1->rows ) {
        my @result = $sth1->fetchrow_array;
        return "No puedes borrar un usuario con nivel mayor o igual que el tuyo" if ($result[1] >= $rlevel);
        my $sth2 = $db->query("delete from users where uid='$result[0]';");
        if ( $sth2 ) {
            return "Usuario $mask borrado del canal $chan";
        } else {
            return "Error al tratar de borrar el usuario";
        }
    } else {
        return "Usuario $nick!$nmask no encontrado en canal $chan";
    }

}

sub userload {

    my (@result, @retval, $entry);
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $sth1 = $db->query("select nick,mask,level,channel from users;");
    if ( $sth1->rows ) {
        while ( @result = $sth1->fetchrow_array ) {
            $entry="$result[0]:$result[1]:$result[2]:$result[3]";
            push (@retval,$entry);
        }
    }
    return @retval;

}
sub botquery {
    my ($package, $nick, $chan, $text, $arg1, $arg2) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $text  = parse($text);
    $chan  =~ s/^#//g;

    # Deal with !link first... query thanx to Clonazo
    my $sth0 = $db->query("select cx2.value from `canal_$chan` AS cx1, `canal_$chan` AS cx2 where cx1.value='$text' AND cx1.link=cx2.id");
    my $link = $sth0->fetchrow;
    if ( $link ) {
        $text=$link;
    }

    my $sth1 = $db->query("select meaning from `canal_$chan` where value = '$text';");
    my $meaning = $sth1->fetchrow;

    if ( $meaning ) {
        # Increse hit count (if linked, the target gets bumped)
        my $sth2 = $db->query("update `canal_$chan` set hits=hits+1 where value = '$text';");
        # start mutators...
        $meaning =~ s/\$0/$nick/g;

        if ( $arg1 ) {
            $arg1    = parse($arg1);
            $meaning =~ s/\$1/$arg1/g;
        }

        if ( $arg2 ) {
            $arg2    = parse($arg2);
            $meaning =~ s/\$2/$arg2/g;
        }

        return ("$meaning");
    } else {
        return ("<no definido>");
    }
}

sub getnext {
    my ($package, $chan, $text) = @_;
    my ($mtext, $ptext);
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");

    # Do I really need this?
    $text = parse($text);

    # Need a (much) better way to do this...
    $ptext = $mtext = $text;
    $mtext =~ s/\+/\\\\\+/g;
    $ptext =~ s/\+/\\+/g;
    $mtext =~ s/\*/\\\\\*/g;
    $ptext =~ s/\*/\\*/g;
    $mtext =~ s/\?/\\\\?/g;
    $chan =~ s/^#//g;
    my $sth1 = $db->query("select value from `canal_$chan` where value REGEXP '^${mtext}" . "[0-9]*\$'");
    my @mlist;
    my @rep;
    my $temp;
    my $res;
    while ( $temp = $sth1->fetchrow ) {
        push (@mlist, $temp);
    }
    # See if it does not need any appendage...
    $res = grep /^${ptext}$/i, @mlist;
    if ($res == 0) { return $text; }

    for (my $lcv=1; $lcv <= 1000; $lcv++) {
        $res = grep /^${ptext}${lcv}$/i, @mlist;
        if ($res == 0) { return "${text}${lcv}"; }
    }

    return 0;
}

sub botnumquery {
    my ($package, $nick, $chan, $text) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $text = parse($text);
    $chan =~ s/^#//g;
    my $sth1 = $db->query("select meaning from `canal_$chan` where id = '$text';");
    my $meaning = $sth1->fetchrow;

    if ( $meaning ) {
        my $sth2 = $db->query("select value from `canal_$chan` where id = '$text';");
        my $val = $sth2->fetchrow;
        return ("$val == $meaning");
    } else {
        return 0;
    }
}

sub botrandquery {
    my ($package, $nick, $chan, $text) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    my $pattern = "";
    $chan =~ s/^#//g;
    if ( $text ) {
        # $text = parse($text);
        # $text =~ s/\*/\%/g;
        # $pattern="where value like '$text'";
        $pattern = parse($text);
        $pattern =~ s/\*/\%/g;
        $pattern="where value like '$pattern'";
    }
    my $sth = $db->query("select value from `canal_$chan` $pattern order by rand() limit 1;");
    my @res = $sth->fetchrow;

    if ( $res[0] ) {
        my $meaning = BotDB->botquery($nick, $chan, $res[0]);
        return ("$res[0] == $meaning");
    } else {
        return ("Pattern ^B$text^B not found...");
    }

}

sub parse {
    my ($string) = @_;
    $string =~ s/\\/\\\\/g;
    $string =~ s/\"/\\\"/g;
    $string =~ s/\'/\\\'/g;
    return ($string);
}

sub link {
    my ($package, $chan, $mask, $linkfrom, $linkto) = @_;
    my $db = Mysql->connect("$dbhost", "$dbname", "$dbuser", "$dbpass");
    $linkfrom  =  parse($linkfrom);
    $linkto    =  parse($linkto);
    $chan      =~ s/^#//g;

    my $sth1 = $db->query("select id from `canal_$chan` where value = '$linkfrom';");
    my $fval = $sth1->fetchrow;

    my $sth2 = $db->query("select id from `canal_$chan` where value = '$linkto';");
    my $tval = $sth2->fetchrow;

    if ( $fval ) {
            return ("Termino $linkfrom ya existe");
    } else {
        if ( $tval ) {
            my $sth3 = $db->query("insert into `canal_$chan` \(value, meaning, author, date, link\) values \('$linkfrom', '', '$mask', now(), '$tval'\);");
            return ("$linkfrom linked to $linkto");
        } else {
            return ("Termino $linkto no existe.");
        }
    } 

}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

BotDB - Perl extension for perlbot

=head1 SYNOPSIS

  use BotDB;
  BotDB->botquery(nick, text);
  BotDB->whoset(nick, text);
  BotDB->learn(nick, mask, value, @meaning);

=head1 DESCRIPTION

This module is intended to aid the perlbot script on it's database functions
=head2 EXPORT

botquery
whoset
learn

=head1 AUTHOR

Alvaro Toledo, E<lt>atoledo@keldon.orgE<gt>

=head1 SEE ALSO

L<perl>.

=cut
