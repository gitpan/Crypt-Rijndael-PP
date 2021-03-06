#!/usr/bin/env perl

use strict;
use warnings;
use bytes;

use Data::Dumper;
use Test::Exception;
use Test::More;

use Storable qw( dclone );

use Crypt::Rijndael::PP;
use Crypt::Rijndael::PP::Debug qw( generate_printable_state );

use Readonly;
Readonly my @INPUT => (
    0xd4, 0x27, 0x11, 0xae,
    0xe0, 0xbf, 0x98, 0xf1,
    0xb8, 0xb4, 0x5d, 0xe5,
    0x1e, 0x41, 0x52, 0x30,
);

Readonly my @EXPECTED_OUTPUT => (
    0xd4, 0xbf, 0x5d, 0x30,
    0xe0, 0xb4, 0x52, 0xae,
    0xb8, 0x41, 0x11, 0xf1,
    0x1e, 0x27, 0x98, 0xe5,
);

Readonly my @ROW         => ( 0xd4, 0xe0, 0xb8, 0x1e );
Readonly my @ROW_SHIFT_0 => ( 0xd4, 0xe0, 0xb8, 0x1e );
Readonly my @ROW_SHIFT_1 => ( 0xe0, 0xb8, 0x1e, 0xd4 );
Readonly my @ROW_SHIFT_2 => ( 0xb8, 0x1e, 0xd4, 0xe0 );
Readonly my @ROW_SHIFT_3 => ( 0x1e, 0xd4, 0xe0, 0xb8 );

subtest "Shift Individual Row" => sub {
    my $packed_row         = pack( "C*", @ROW );
    my $packed_row_shift_0 = pack( "C*", @ROW_SHIFT_0 );
    my $packed_row_shift_1 = pack( "C*", @ROW_SHIFT_1 );
    my $packed_row_shift_2 = pack( "C*", @ROW_SHIFT_2 );
    my $packed_row_shift_3 = pack( "C*", @ROW_SHIFT_3 );

    my $unshifted_row = [
        unpack("x0a", $packed_row ),
        unpack("x1a", $packed_row ),
        unpack("x2a", $packed_row ),
        unpack("x3a", $packed_row ),
    ];

    subtest "Shift Row 0 Bytes" => sub {
        my $row = dclone $unshifted_row;

        lives_ok {
            Crypt::Rijndael::PP->_shift_row( $row, 0 );
        } "Lives through row shifting";

        is_deeply( $row, [
            unpack("x0a", $packed_row_shift_0 ),
            unpack("x1a", $packed_row_shift_0 ),
            unpack("x2a", $packed_row_shift_0 ),
            unpack("x3a", $packed_row_shift_0 ),
        ] , "Correct Resultant Row" );
    };

    subtest "Shift Row 1 Byte" => sub {
        my $row = dclone $unshifted_row;

        lives_ok {
            Crypt::Rijndael::PP->_shift_row( $row, 1 );
        } "Lives through row shifting";

        is_deeply( $row, [
            unpack("x0a", $packed_row_shift_1 ),
            unpack("x1a", $packed_row_shift_1 ),
            unpack("x2a", $packed_row_shift_1 ),
            unpack("x3a", $packed_row_shift_1 ),
        ] , "Correct Resultant Row" );
    };

    subtest "Shift Row 2 Bytes" => sub {
        my $row = dclone $unshifted_row;

        lives_ok {
            Crypt::Rijndael::PP->_shift_row( $row, 2 );
        } "Lives through row shifting";

        is_deeply( $row, [
            unpack("x0a", $packed_row_shift_2 ),
            unpack("x1a", $packed_row_shift_2 ),
            unpack("x2a", $packed_row_shift_2 ),
            unpack("x3a", $packed_row_shift_2 ),
        ] , "Correct Resultant Row" );
    };

    subtest "Shift Row 3 Bytes" => sub {
        my $row = dclone $unshifted_row;

        lives_ok {
            Crypt::Rijndael::PP->_shift_row( $row, 3 );
        } "Lives through row shifting";

        is_deeply( $row, [
            unpack("x0a", $packed_row_shift_3 ),
            unpack("x1a", $packed_row_shift_3 ),
            unpack("x2a", $packed_row_shift_3 ),
            unpack("x3a", $packed_row_shift_3 ),
        ] , "Correct Resultant Row" );
    };
};

subtest "Perform ShiftRows on Input State" => sub {
    my $packed_input = pack( "C*", @INPUT );
    my $state = Crypt::Rijndael::PP->_input_to_state( $packed_input );

    note("Original State:\n");
    note( generate_printable_state( $state ) );

    my $packed_expected_output = pack( "C*", @EXPECTED_OUTPUT );
    my $expected_state = Crypt::Rijndael::PP->_input_to_state(
        $packed_expected_output
    );

    my $updated_state;
    lives_ok {
        $updated_state = Crypt::Rijndael::PP->_ShiftRows( $state );
    } "Lives through ShiftRows";

    note("Updated State:\n");
    note( generate_printable_state( $updated_state ) );

    note("Expected State:\n");
    note( generate_printable_state( $expected_state ) );

    my $byte_index = 0;
    for ( my $row_index = 0; $row_index < 4; $row_index++ ) {
        for ( my $column_index = 0; $column_index < 4; $column_index++ ) {

            my $state_byte = unpack( "H2",
                $updated_state->[$row_index][$column_index]
            );

            my $expected_state_byte = unpack( "H2",
                $expected_state->[$row_index][$column_index]
            );

            cmp_ok( $state_byte, 'eq', $expected_state_byte,
                "Correct SubByte State Byte at $row_index x $column_index" );
        }
    }
};

done_testing;
