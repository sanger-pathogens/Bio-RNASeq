=head1 NAME

VertRes::Utils::FileSystem - do filesystem manipulations

=head1 SYNOPSIS

use VertRes::Utils::FileSystem;

my $fsu = VertRes::Utils::FileSystem->new();

# ...


# generally useful file-related functions
my $base_dir = $fsu->catfile($G1K, 'META');
my @paths = $fsu->get_filepaths($base_dir, suffix => 'fastq.gz');
my ($tempfh, $tempfile) = $fsu->tempfile();
my $tempdir = $fsu->tempdir;
$fsu->rmtree($directory_structure_safe_to_delete); # !! CAREFULL !!

=head1 DESCRIPTION

Provides functions related to storing/getting things on/from the file-system.

Also provides aliases to commonly needed file-related functions: tempfile,
tempdir, catfile, rmtree.

=head1 AUTHOR

Sendu Bala: bix@sendu.me.uk

=cut

package VertRes::Utils::FileSystem;

use strict;
use warnings;
use Debug;

no warnings 'recursion';

use Cwd qw(abs_path cwd);
use File::Temp;
use File::Spec;
use File::Basename;
require File::Path;
require File::Copy;
use Digest::MD5;
use Filesys::DfPortable;
use Filesys::DiskUsage qw/du/;
use File::Rsync;
use Debug;

use base qw(VertRes::Base);

my $debug = Debug->new();

$debug->sr('new');
$debug->where('before');
$debug->print_where();

=head2 new

 Title   : new
 Usage   : my $self = $class->SUPER::new(@args);
 Function: Instantiate a new VertRes::Utils::FileSystem object.
 Returns : $self hash-ref blessed into your class
 Args    : n/a

=cut

sub new {
  my ($class, @args) = @_;

  $debug->where('In');
  $debug->print_where();

  my $self = $class->SUPER::new(@args);

  return $self;
}

$debug->where('out');
$debug->print_where();

=head2 get_filepaths

 Title   : get_filepaths
 Usage   : my @paths = $obj->get_filepaths('base_dir'); 
 Function: Get the absolute paths to all files in a given directory and all its
           subdirectories.
 Returns : a list of filepaths
 Args    : path to base directory
           optionally, the following named args select out only certain paths
           according to if they match the supplied regex string(s)
           filename => regex (whole basename of file must match regex)
           prefix   => regex (basename up to the final '.' must match regex)
           suffix   => regex (everything after the final '.' must match regex;
                              the '.' in .gz is not treated as the final '.' for
                              this purpose)
           dir      => regex (return directory paths that match, instead of
                              files - disables above 3 options)
           subdir   => regex (at least one of a file/dir's parent directory must
                              match regex)

=cut

$debug->sr('get_filepaths');
$debug->where('before');
$debug->print_where();

sub get_filepaths {
    my ($self, $dir, %args) = @_;

    $debug->where('In');
    $debug->print_where();

    $dir = abs_path($dir);
    my $wanted_dir = $args{dir};
    opendir(my $dir_handle, $dir) || $self->throw("Couldn't open dir '$dir': $!");
    
    my @filepaths;
    foreach my $thing (readdir($dir_handle)) {
        next if $thing =~ /^\.+$/;
        my $orig_thing = $thing;
        $thing = $self->catfile($dir, $thing);
        
        # recurse into subdirs
        if (-d $thing) {
            if ($wanted_dir && $orig_thing =~ /$wanted_dir/) {
                if (($args{subdir} && $thing =~ /$args{subdir}/) || ! $args{subdir}) {
                    push(@filepaths, $thing);
                }
            }
            
            push(@filepaths, $self->get_filepaths($thing, %args));
            next;
        }
        
        next if $wanted_dir;
        
        # check it matches user's regexs
        my $ok = 1;
        my ($basename, $directories) = fileparse($thing);
        my $gz = '';
        if ($basename =~ s/\.gz$//) {
            $gz = '.gz';
        }
        my ($prefix, $suffix) = $basename =~ /(.+)\.(.+)$/;
        unless ($prefix) {
            # we have a .filename file
            $suffix = $basename;
        }
        $suffix .= $gz;
        $basename .= $gz;
        while (my ($type, $regex) = each %args) {
            if ($type eq 'filename') {
                $basename =~ /$regex/ || ($ok = 0);
            }
            elsif ($type eq 'prefix') {
                unless ($prefix) {
                    $ok = 0;
                }
                else {
                    $prefix =~ /$regex/ || ($ok = 0);
                }
            }
            elsif ($type eq 'suffix') {
                unless ($suffix) {
                    $ok = 0;
                }
                else {
                    $suffix =~ /$regex/ || ($ok = 0);
                }
            }
            elsif ($type eq 'subdir') {
                $directories =~ /$regex/ || ($ok = 0);
            }
        }
        
        push(@filepaths, $thing) if $ok;
    }
    
    return @filepaths;
}

$debug->where('out');
$debug->print_where();

=head2 tempfile

 Title   : tempfile
 Usage   : my ($handle, $tempfile) = $obj->tempfile(); 
 Function: Get a temporary filename and a handle opened for writing and
           and reading. Just an alias to File::Temp::tempfile.
 Returns : a list consisting of temporary handle and temporary filename
 Args    : as per File::Temp::tempfile

=cut

$debug->sr('tempfile');
$debug->where('before');
$debug->print_where();

sub tempfile {
    my $self = shift;

    $debug->where('In');
    $debug->print_where();

    my $ft = File::Temp->new(@_);
    push(@{$self->{_fts}}, $ft);
    
    return ($ft, $ft->filename);
}

$debug->where('out');
$debug->print_where();

=head2 tempdir

 Title   : tempdir
 Usage   : my $tempdir = $obj->tempdir(); 
 Function: Creates and returns the name of a new temporary directory. Just an
           alias to File::Temp::newdir.
 Returns : The name of a new temporary directory.
 Args    : as per File::Temp::newdir

=cut

$debug->sr('tempdir');
$debug->where('before');
$debug->print_where();

sub tempdir {
    my $self = shift;
    
    my $ft = File::Temp->newdir(@_);
    push(@{$self->{_fts}}, $ft);
    
    return $ft->dirname;
}

$debug->where('out');
$debug->print_where();

=head2 catfile

 Title   : catfile
 Usage   : my ($path) = $obj->catfile('dir', 'subdir', 'filename'); 
 Function: Constructs a full pathname in a cross-platform safe way. Just an
           alias to File::Spec->catfile.
 Returns : the full path
 Args    : as per File::Spec->catfile

=cut

$debug->sr('catfile');
$debug->where('before');
$debug->print_where();

sub catfile {
    my $self = shift;

    $debug->where('In');
    $debug->print_where();

    return File::Spec->catfile(@_);
}

$debug->where('out');
$debug->print_where();

=head2 rmtree

 Title   : rmtree
 Usage   : $obj->rmtree('dir'); 
 Function: Remove a full directory tree - files and subdirs. Just an alias to
           File::Path::rmtree.
 Returns : n/a
 Args    : as per File::Path::rmtree

=cut

$debug->sr('rmtree');
$debug->where('before');
$debug->print_where();

sub rmtree {
    my $self = shift;
    return File::Path::rmtree(@_);
}

$debug->where('out');
$debug->print_where();

=head2 verify_md5

 Title   : verify_md5
 Usage   : if ($obj->verify_md5($file, $md5)) { #... }
 Function: Verify that a given file has the given md5.
 Returns : boolean
 Args    : path to file, the expected md5 (hexdigest as produced by the md5sum
           program) as a string

=cut

$debug->sr('verify_md5');
$debug->where('before');
$debug->print_where();

sub verify_md5 {
    my ($self, $file, $md5) = @_;

    $debug->where('In');
    $debug->print_where();

    my $new_md5 = $self->calculate_md5($file);
    return $new_md5 eq $md5;
}

$debug->where('out');
$debug->print_where();

=head2 calculate_md5

 Title   : calculate_md5
 Usage   : my $md5 = $obj->calculate_md5($file)
 Function: Calculate the md5 of a file.
 Returns : hexdigest string
 Args    : path to file

=cut

$debug->sr('calculate_md5');
$debug->where('before');
$debug->print_where();

sub calculate_md5 {
    my ($self, $file, $md5_file) = @_;

    $debug->where('In');
    $debug->print_where();

    open(my $fh, $file) || $self->throw("Could not open file $file");
    binmode($fh);
    my $dmd5 = Digest::MD5->new();
    $dmd5->addfile($fh);
    my $md5 = $dmd5->hexdigest;
    close $fh;
    
    if ($md5_file) {
        open(my $mdfh, ">$md5_file") || $self->throw("Could not open file $md5_file");
        print $mdfh "$md5  $file\n";
        close $mdfh;
    }
    
    return $md5;
}

$debug->where('out');
$debug->print_where();

=head2 md5_from_file

 Title   : md5_from_file
 Usage   : $md5 = $obj->md5_from_file($file)
 Function: Verify that a given file has the given md5.
 Returns : hexdigest string
 Args    : path to file, the expected md5 (hexdigest as produced by the md5sum
           program) as a string

=cut

$debug->sr('md5_from_file');
$debug->where('before');
$debug->print_where();

sub md5_from_file {
    my ($self, $file) = @_;

    $debug->where('In');
    $debug->print_where();

    open my $fh, "<$file" || $self->throw("Could not open $file to read md5");
    my ($md5) = <$fh> =~ m/^([0-9a-z]{32})\s/;
    close $fh;
    $md5 || $self->throw("Could not read md5 from $file");
    return $md5;
}

$debug->where('out');
$debug->print_where();

=head2 directory_structure_same

 Title   : directory_structure_same
 Usage   : if ($obj->directory_structure_same($root1, $root2)) { ... }
 Function: Find out if two directory structures are identical. (files are
           ignored by default)
 Returns : boolean
 Args    : two absolute paths to root directories to compare, optionally a hash
           of extra options:
           leaf_mtimes => \%hash (the hash ref will have a single key added to
                                  it of the first root path, where the value
                                  is another hash ref. That hash will have keys
                                  as leaf directory names and their mtimes as
                                  values)
           consider_files => boolean (default false; when true, directory
                                      structures are only considered the same if
                                      they also share the same files, and if
                                      files in the first root are all older
                                      or the same age as the corresponding file
                                      in the second root)

=cut

$debug->sr('directory_structure_same');
$debug->where('before');
$debug->print_where();

sub directory_structure_same {
    my ($self, $root1, $root2, %opts) = @_;

    $debug->where('In');
    $debug->print_where();

    my $orig_path = delete $opts{orig_path};
    $orig_path ||= $root1;
    
    -d $root1 || return 0;
    -d $root2 || return 0;
    $root1 =~ s/\/$//;
    $root2 =~ s/\/$//;
    
    # on lustre 'find' is orders of magnitude faster than using 'ls' or perl
    # 'opendir'&'readdir'.
    my $type = $opts{consider_files} ? '' : '-type d';
    open(my $dh1, "find $root1 $type |") || $self->throw("failed to open a pipe to find");
    open(my $dh2, "find $root2 $type |") || $self->throw("failed to open a pipe to find");
    my %root1;
    while (<$dh1>) {
        chomp;
        s/^$root1\/?//;
        next unless /\S/;
        next if /^_/;
        $root1{$_} = 1;
    }
    my %root2;
    while (<$dh2>) {
        chomp;
        s/^$root2\/?//;
        next unless /\S/;
        next if /^_/;
        $root2{$_} = 1;
    }
    close($dh1);
    close($dh2);
    
    # compare the structures
    foreach my $path (keys %root1) {
        if (defined $root2{$path}) {
            delete $root2{$path};
        }
        else {
            return 0;
        }
    }
    if (keys %root2) {
        return 0;
    }
    
    # make sure root2 files aren't newer than root1 files
    if ($opts{consider_files}) {
        foreach my $path (keys %root1) {
            my $this_path = File::Spec->catdir($root1, $path);
            my $other_path = File::Spec->catdir($root2, $path);
            
            if (! -d $this_path) {
                my @this_s = stat($this_path);
                my @other_s = stat($other_path);
                
                unless ($this_s[9] <= $other_s[9]) {
                    return 0;
                }
            }
        }
    }
    
    # get the leaf times
    if ($opts{leaf_mtimes}) {
        # pick out the dirs
        my %dirs;
        if ($opts{consider_files}) {
            foreach my $path (keys %root1) {
                if (-d $path) {
                    $dirs{$path} = 1;
                }
            }
        }
        else {
            %dirs = %root1;
        }
        
        # figure out which ones are leaves and store their mtimes
        my %leaves;
        foreach my $path (keys %dirs) {
            my $is_parent = 0;
            foreach my $other_path (keys %dirs) {
                next if $path eq $other_path;
                if ($other_path =~ /^$path/) {
                    $is_parent = 1;
                    last;
                }
            }
            
            unless ($is_parent) {
                my @s = stat(File::Spec->catdir($root1, $path));
                $opts{leaf_mtimes}->{$root1}->{basename($path)} = $s[9];
            }
        }
    }
    
    return 1;
}

$debug->where('out');
$debug->print_where();

=head2 hashed_path

 Title   : hashed_path
 Usage   : my $hashed_path = $obj->hashed_path('/abs/path/to/dir');
 Function: Convert a certain path to a 4-level deep hashed path based on the
           md5 digest of the input path. Eg. use the returned path as the place
           to move a directory to on a new disc, so spreading dirs out evenly
           and not having too many dirs in a single folder.
 Returns : string
 Args    : absolute path

=cut

$debug->sr('hashed_path');
$debug->where('before');
$debug->print_where();

sub hashed_path {
    my ($self, $path) = @_;

    $debug->where('In');
    $debug->print_where();

    my $dmd5 = Digest::MD5->new();
    $dmd5->add($path);
    my $md5 = $dmd5->hexdigest;
    my @chars = split("", $md5);
    my $basename = basename($path);
    return $self->catfile(@chars[0..3], $basename);
}

$debug->where('out');
$debug->print_where();

=head2 can_be_copied

 Title   : can_be_copied
 Usage   : if ($obj->can_be_copied('/abs/.../source', '/abs/.../dest')) { ... }
 Function: Find out of there is enough disc space at a destination to copy
           a source directory/file to.
 Returns : boolean
 Args    : two absolute paths (source and destination)

=cut

$debug->sr('can_be_copied');
$debug->where('before');
$debug->print_where();

sub can_be_copied {
    my ($self, $source, $destination) = @_;

    $debug->where('In');
    $debug->print_where();

    my $usage = $self->disk_usage($source) || 0;
    my $available = $self->disk_available($destination) || return 0;
    return $available > $usage;
}

$debug->where('out');
$debug->print_where();

=head2 disk_available

 Title   : disk_available
 Usage   : my $bytes_left = $obj->disk_available('/path');
 Function: Find out how much disk space is available on the disk the supplied
           path is mounted on. This is how much is available to the current
           user (so considers quotas), not the total free space on the disk.
 Returns : int
 Args    : path string

=cut

$debug->sr('disk_available');
$debug->where('before');
$debug->print_where();

sub disk_available {
    my ($self, $path) = @_;

    $debug->where('In');
    $debug->print_where();

    my $ref = dfportable($path) || (return 0);
    return $ref->{bavail};
}

$debug->where('out');
$debug->print_where();

=head2 disk_usage

 Title   : disk_usage
 Usage   : my $bytes_used = $obj->disk_usage('/path');
 Function: Find out how much disk space a file or directory is using up.
 Returns : int
 Args    : path string

=cut

$debug->sr('disk_usage');
$debug->where('before');
$debug->print_where();

sub disk_usage {
    my ($self, $path) = @_;

    $debug->where('In');
    $debug->print_where();

    my $total = du($path);
    return $total || 0;
}

$debug->where('out');
$debug->print_where();

=head2 set_stripe_dir

 Title   : set_stripe_dir
 Usage   : my $stripe = $obj->set_stripe_dir('dir', '-1');
 Function: Set the Lustre striping for large or small files (note only subsequent file writes will be affected)
 Returns : boolean
 Args    : path (string) and an int (stripe value)

=cut

$debug->sr('set_stripe_dir');
$debug->where('before');
$debug->print_where();

sub set_stripe_dir {
    my ($self, $path, $stripe_value) = @_;
    $debug->where('In');
    $debug->print_where();

    if ($stripe_value < -1 || $stripe_value > 10) {
        $self->throw("Invalid stripe value: $stripe_value");
    }
    
    #it should first check the striping and see if necessary
    
    print "Setting stripe for $path\n";
    system( "lfs setstripe -c $stripe_value $path" ) == 0 or $self->throw( "Failed to set stripe on directory: $path" );
    
    return 1;
}

$debug->where('out');
$debug->print_where();

=head2 set_stripe_dir_tree

 Title   : set_stripe_dir_tree
 Usage   : my $stripe = $obj->set_stripe_dir_tree('root_dir', '-1');
 Function: Set the Lustre striping for large or small files on a whole directory tree
 Returns : boolean
 Args    : path (string) stripe value (int)

=cut

$debug->sr('set_stripe_dir_tree');
$debug->where('before');
$debug->print_where();

sub set_stripe_dir_tree {
    my ($self, $root, $stripe_value) = @_;
    $debug->where('In');
    $debug->print_where();


    if ($stripe_value < -1 || $stripe_value > 10) {
        $self->throw("Invalid stripe value: $stripe_value");
    }
    
    chdir( $root ) or $self->throw( "can't find $root: $!" );
    opendir(my $dfh, '.') or $self->throw( "can't open current directory: $!" );
    while( defined( my $file = readdir( $dfh ) ) ) {
        next unless -d $file;
        next unless $file !~ /^\.+$/ && $file !~ /^_Inline$/;
        next if( -l $file );
        
        $self->set_stripe_dir( $file, $stripe_value ); #set the stripe
        print "Recursing into $file\n";
        $self->set_stripe_dir_tree( $file, $stripe_value ); #recurse into the directory also
        chdir( ".." )
    }
    closedir($dfh);
}

$debug->where('out');
$debug->print_where();

1;
