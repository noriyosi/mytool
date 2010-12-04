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
my $CHECK_EXTENSIONS = undef; # �g���q�`�F�b�N����ꍇ�� 1 �ɕύX
my @ALLOW_EXTENSIONS = qw/cpp h inl mmp inf def cia oby bat pl bin mmh iby inc s/;

# �G���[���O�p�N���X�^�I�u�W�F�N�g
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

# �v���t�B�N�X�t���̃t�@�C�����̏ꍇ�A�T�u�f�B���N�g���z���̃t�@�C�����X�g��
# �V�����X�N���v�g���쐬����B
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

    # �g���q�`�F�b�N�p�̃n�b�V�����쐬
    my %check_hash = map {$_ => 1} @ALLOW_EXTENSIONS;
    my $find_fn = sub {
        /\.([^.]+)$/;

        # �Y������g���q�̏ꍇ�̓��X�g�Ƃ��ďo��
        if (-f && (!$CHECK_EXTENSIONS || ($1 && $check_hash{$1}))) {

            # �쐬�t�@�C�������܂܂�Ă���ꍇ�̓��X�g�o�͂��Ȃ��B
            # �i�G���[�o�͗p�̃t�@�C����{�t�@�C�������X�g�Ɋ܂߂Ȃ����߁j
            if ((index $File::Find::name, $new_file) < 0) { 
                # ���X�g�o��
                print OUT substr($File::Find::name, 2), "\n";
            }
        }
    };
    find($find_fn, '.');
    close OUT;
    1;
}

# �w�肳�ꂽ�f�B���N�g�����쐬����B�e�f�B���N�g�����Ȃ��ꍇ�͂�����쐬����B
sub mkdir_p
{
    my $dir = shift;
    return if (-d $dir);

    mkdir_p(dirname $dir);
    mkdir $dir;
}

# ���̃t�@�C�������̃��X�g����R�s�[�t�@�C���̃��X�g���쐬
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
    # ��r�f�B���N�g���ɓ��t��t�����ďo�͐�f�B���N�g�������쐬
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
    # �t�@�C�����̊g���q�����Ńf�B���N�g���쐬
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

