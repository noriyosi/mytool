#!C:\Perl\bin\perl.exe

use strict;
use warnings;
use utf8;
use File::Find;
use File::Copy;
use File::Basename;
use File::Compare;
use POSIX qw/strftime/;

my $UPDATE_PREFIX = 'up_';
my $DIFF_PREFIX = 'df_';
my $CHECK_EXTENSIONS = undef; # 拡張子チェックする場合は 1 に変更
my @ALLOW_EXTENSIONS = qw/cpp h inl mmp inf def cia oby bat pl bin mmh iby inc s/;

# エラーログ用クラス／オブジェクト
{
    package ErrLog;
    my $error = undef;
    my $ERROR_LOG_FILE = "$0_error.txt";
    sub new {
        my $self = {error => undef};
        open ERR, ">", $ERROR_LOG_FILE or die "$!";
        return bless $self, shift;
    }
    sub p {
        my $self = shift;
        $self->{error} = 1;
        print ERR shift, "\n";
    }
    sub DESTROY {
        close ERR;
        if (!$_[0]->{error}) {
            unlink $ERROR_LOG_FILE;
        }
    }
}
my $err = ErrLog->new;

# プレフィクス付きのファイル名の場合、サブディレクトリ配下のファイルリストで
# 新しいスクリプトを作成する。
sub update_list
{
    my $this_file = (basename $0);
    return undef until $this_file =~ /^$UPDATE_PREFIX/;

    open IN, "<", $0 or die "can't open : $0";
    my $new_file = substr($this_file, length $UPDATE_PREFIX);
    open OUT, ">", $new_file or die "can't open : $new_file";

    while (<IN>) {
        print OUT;
        last if /^__END__/;
    }
    close IN;

    # 拡張子チェック用のハッシュを作成
    my %check_hash = map {$_ => 1} @ALLOW_EXTENSIONS;
    my $find_fn = sub {
        /\.([^.]+)$/;

        # 該当する拡張子の場合はリストとして出力
        if (-f && (!$CHECK_EXTENSIONS || ($1 && $check_hash{$1}))) {

            # 作成ファイル名が含まれている場合はリスト出力しない。
            # （エラー出力用のファイルや本ファイルをリストに含めないため）
            if ((index $File::Find::name, $new_file) < 0) { 
                # リスト出力
                print OUT substr($File::Find::name, 2), "\n";
            }
        }
    };
    find($find_fn, '.');
    close OUT;
    1;
}

# 指定されたディレクトリを作成する。親ディレクトリがない場合はそれも作成する。
sub mkdir_p
{
    my $dir = shift;
    return if (-d $dir);

    mkdir_p(dirname $dir);
    mkdir $dir;
}

# このファイル末尾のリストからコピーファイルのリストを作成
sub get_list
{
    open IN, "<", $0 or die "$0: $!";
    while (<IN>) {
        last if /^__END__/;
    }
    my @list = ();
    while (<IN>) {
        next if /^\s*$/;
        next if /^#/;
        s/[\r\n]*$//;
        push @list, $_;
    }
    close IN;
    \@list;
}

sub get_latest_dir
{
    (basename $0) =~ /^$DIFF_PREFIX(.*)\.[^.]+$/;
    opendir DIR, ".";
    my @list = sort grep { /^$1_[0-9]{8}_[0-9]{6}$/ } readdir DIR;
    closedir DIR;
    pop @list;
}

sub copy_file
{
    my ($from, $to) = @_;
    mkdir_p(dirname $to);
    copy $from, $to or $err->p("fail to copy: $from -> $to :$!");
}

sub pickup_diff
{
    # 比較ディレクトリに日付を付加して出力先ディレクトリ名を作成
    my $latest_dir = get_latest_dir();
    my $dist_dir = strftime "$latest_dir-%Y%m%d_%H%M%S", localtime;
    mkdir $dist_dir or die "can't create dir";

    my @result = ();
    my $comp_fn = sub {
        my $file = shift;
        if (compare $file, "$latest_dir/$file") {
            copy_file $file, "$dist_dir/$file";
            push @result, "M $file";
        }
    };

    my $add_fn = sub {
        my $file = shift;
        push @result, "A $file";
        copy_file $file, "$dist_dir/$file";
    };

    foreach my $file (@{get_list()}) {
        (not -e "$latest_dir/$file") ? $add_fn->($file)        :
        (not -e "$file")             ? push @result, "D $file" :
                                       $comp_fn->($file);
    }

    system "diff -ru $latest_dir $dist_dir > $dist_dir/diff.txt";

    open DIFF_RET, ">", "$dist_dir/list.txt" or $err->p($!);
    map { print DIFF_RET $_, "\n"; } sort @result;
    close DIFF_RET;
}

sub pickup
{
    # ファイル名の拡張子抜きでディレクトリ作成
    $0 =~ /^(.*)\.[^.]+$/;
    my $dist_dir =  strftime "$1_%Y%m%d_%H%M%S", localtime;
    mkdir $dist_dir or die "can't create dir";

    map { copy_file $_, "$dist_dir/$_" } @{get_list()};
}

######### main
exit 0 if update_list();

(basename $0) =~ /^$DIFF_PREFIX/ ? pickup_diff() : pickup();

__END__
work/sh_backup/pickup.pl

