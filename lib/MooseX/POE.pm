package MooseX::POE;
{
  $MooseX::POE::VERSION = '0.215';
}
# ABSTRACT: The Illicit Love Child of Moose and POE

use Moose ();
use Moose::Exporter;

my ( $import, $unimport, $init_meta ) = Moose::Exporter->setup_import_methods(
    with_caller     => [qw(event)],
    also            => 'Moose',
    install         => [qw(import unimport)],
    class_metaroles => {
        class       => ['MooseX::POE::Meta::Trait::Class'],
        instance    => ['MooseX::POE::Meta::Trait::Instance'],
    },
    base_class_roles => ['MooseX::POE::Meta::Trait::Object'],
);

sub init_meta {
    my ( $class, %args ) = @_;

    my $for = $args{for_class};
    eval qq{package $for; use POE; };

    Moose->init_meta( for_class => $for );

    goto $init_meta;
}

sub event {
    my ( $caller, $name, $method ) = @_;
    my $class = Moose::Meta::Class->initialize($caller);
    $class->add_state_method( $name => $method );
}

1;


=pod

=head1 NAME

MooseX::POE - The Illicit Love Child of Moose and POE

=head1 VERSION

version 0.215

=head1 SYNOPSIS

    package Counter;
    use MooseX::POE;

    has count => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        default => sub { 0 },
    );

    sub START {
        my ($self) = @_;
        $self->yield('increment');
    }

    event increment => sub {
        my ($self) = @_;
        print "Count is now " . $self->count . "\n";
        $self->count( $self->count + 1 );
        $self->yield('increment') unless $self->count > 3;
    };

    no MooseX::POE;

    Counter->new();
    POE::Kernel->run();

or with L<MooseX::Declare|MooseX::Declare>:

    class Counter {
        use MooseX::POE::SweetArgs qw(event);
        
        has count => (
            isa     => 'Int',
            is      => 'rw',
            lazy    => 1,
            default => sub { 0 },
        );
        
        sub START { 
            my ($self) = @_;
            $self->yield('increment')  
        }
        
        event increment => sub {
            my ($self) = @_;
            print "Count is now " . $self->count . "\n";
            $self->count( $self->count + 1 );
            $self->yield('increment') unless $self->count > 3;            
        }
    }

    Counter->new();
    POE::Kernel->run();

=head1 DESCRIPTION

MooseX::POE is a L<Moose> wrapper around a L<POE::Session>.

=head1 METHODS

=head2 event $name $subref

Create an event handler named $name. 

=head2 get_session_id

Get the internal POE Session ID, this is useful to hand to other POE aware
functions.

=head2 yield

=head2 call

=head2 delay

=head2 alarm

=head2 alarm_add

=head2 delay_add

=head2 alarm_set

=head2 alarm_adjust

=head2 alarm_remove

=head2 alarm_remove_all

=head2 delay_set

=head2 delay_adjust

A cheap alias for the same POE::Kernel function which will gurantee posting to the object's session.

=head2 STARTALL

=head2 STOPALL

=head1 KEYWORDS

=head1 METHODS

Default POE-related methods are provided by L<MooseX::POE::Meta::Trait::Object|MooseX::POE::Meta::Trait::Object>
which is applied to your base class (which is usually L<Moose::Object|Moose::Object>) when
you use this module. See that module for the documentation for. Below is a list
of methods on that class so you know what to look for:

=head1 NOTES ON USAGE WITH L<MooseX::Declare>

L<MooseX::Declare|MooseX::Declare> support is still "experimental". Meaning that I don't use it,
I don't have any code that uses it, and thus I can't adequately say that it
won't cause monkeys to fly out of any orifices on your body beyond what the
tests and the SYNOPSIS cover. 

That said there are a few caveats that have turned up during testing. 

1. The C<method> keyword doesn't seem to work as expected. This is an
integration issue that is being resolved but I want to wait for
L<MooseX::Declare|MooseX::Declare> to gain some more polish on their slurpy
arguments.

2. MooseX::POE attempts to re-export L<Moose>, which
L<MooseX::Declare> has already exported in a custom fashion.
This means that you'll get a keyword clash between the features that
L<MooseX::Declare|MooseX::Declare> handles for you and the features that Moose
handles. To work around this you'll need to write:

    use MooseX::POE qw(event);
    # or
    use MooseX::POE::SweetArgs qw(event);
    # or 
    use MooseX::POE::Role qw(event);

to keep MooseX::POE from exporting the sugar that
L<MooseX::Declare|MooseX::Declare> doesn't like. This is fixed in the Git
version of L<MooseX::Declare|MooseX::Declare> but that version (as of this
writing) is not on the CPAN.

=head1 SEE ALSO

=for :list * L<Moose|Moose> 
* L<POE|POE>

=head1 AUTHORS

=over 4

=item *

Chris Prather <chris@prather.org>

=item *

Ash Berlin <ash@cpan.org>

=item *

Chris Williams <chris@bingosnet.co.uk>

=item *

Yuval (nothingmuch) Kogman

=item *

Torsten Raudssus <torsten@raudssus.de> L<http://www.raudssus.de/>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Chris Prather, Ash Berlin, Chris Williams, Yuval Kogman, Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

