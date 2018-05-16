# /SCRIPT [UN]LOAD osd.pl
# /OSDMUTE   - (un)mutes the active channel
#
# Irssi script which displays chat lines one by one at the bottom of the desktop
#
# PURPOSE:
#	follow a (slow) chat while working, without having to check 
#	the Irssi window for new messages every time
#
# FEATURES:
#	- different colors for different channels
#	- OSD only appears if Irssi is invisible
#	- mute noisy channels with `/osdmute` in Irssi
#	- indicates muted channels `[OSDMUTE]` in statusbar
#
# REQUIRES:
#	- Linux and X11
#	- `libxosd` installed (Slackware: system/xosd)
#	- `X::Osd` perl module installed via `perl -MCPAN -e 'install X::Osd'`
#	  
# TODO:
#	- hackish but good enough at the moment
#	- if messages follow too fast then stack messages 
#	- long texts (> 4x60)
#	- special color/effect if user is highlighted
#	- direct calls to libxosd's `osd_cat` executable or `aosd_cat` bc less deps? 
#	
# REFERENCES:
#	- https://github.com/shabble/irssi-docs/wiki
#	
#

use v5.10.0;
use strict;
use X::Osd;
use Irssi;
use Irssi::TextUI;  # statusbar_item_register


our $VERSION = '2018-04-05';
our %IRSSI =
(
	authors     => 'datakadabra.wordpress.com',
	contact     => 'datakadabra@gmail.com',
	url         => 'https://github.com/andre-st/irssi-plugins',
	name        => 'osd',
	description => 'Display chat lines one by one at the bottom of the X11 desktop',
	created     => '2011-02-05',
	changed     => $VERSION,
	license     => 'CC-BY-SA',
);



our @_avail_colors = ( 'lightblue', 'magenta', 'orange', 'yellow', 'green' ); # X11 rgb.txt
our %_color_for    = (); # key: string channel name    - predefine if you like
our @_muted_chans  = (); # strings                     - predefine if you like
our $_osd          = X::Osd::create( 4 );
our $_osd_width    = 60; # max chars per line


# Initialize:
$_osd->set_font             ( '-*-helvetica-bold-r-normal-*-17-*-*-*-*-*-*-*' );
$_osd->set_pos              ( XOSD_bottom );
$_osd->set_align            ( XOSD_center );
$_osd->set_timeout          ( 5           );
$_osd->set_horizontal_offset( 0           );
$_osd->set_vertical_offset  ( 10          );
$_osd->set_colour           ( 'green'     );
$_osd->set_outline_colour   ( 'black'     );
$_osd->set_outline_offset   ( 2           );
$_osd->set_shadow_offset    ( 0           );


$_osd->string( 0, 'Irssi OSD plugin loaded'           );
$_osd->string( 1, 'Text appears unless you see Irssi' );


Irssi::signal_add_last( 'print text', 'sig_text_printed' );
Irssi::command_bind   ( 'osdmute',    'cmd_osdmute'      );

Irssi::expando_create         ( 'osd', 'handle_expando', {}        );
Irssi::statusbar_item_register( 'osd', '$0', 'draw_statusbar_item' );
Irssi::command( 'statusbar window       add osd' );
Irssi::command( 'statusbar window_inact add osd' );



sub handle_expando
	# returns string
{
	my $server = shift;  # Irssi::Server
	my $witem  = shift;  # Irssi::WindowItem
	return is_muted( $witem->{name} ) ? 'OSDMUTE' : '';
}


sub draw_statusbar_item
	# returns void
{
	my $sb_item = shift;  # Irssi::TextUI::StatusbarItem
	my $sz_only = shift;  # ?
	$sb_item->default_handler( $sz_only, '{sb $osd}', undef, 1 );
}


sub find_my_xwindow_id
	# returns string or undef
{
	return $ENV{WINDOWID} or undef;
}


sub is_osd_sensible_now
	# returns bool
{
	my $irssi_win_id     = find_my_xwindow_id() or return 1;
	my $is_irssi_visible = `xwininfo -id $irssi_win_id | grep IsViewable`;
	return !$is_irssi_visible;
}


sub get_channel_color
	# returns string
{
	my $channel = shift;  # string
	if( !exists $_color_for{$channel} )
	{	
		$_color_for{$channel} = @_avail_colors ? pop @_avail_colors : 'white';
	}
	
	return $_color_for{$channel};
}


sub cmd_osdmute  
	# returns void
{
	my $args   = shift;  # string
	my $server = shift;  # Irssi::Irc::Server
	my $witem  = shift;  # Irssi::Irc::WindowItem
	my $wname  = $witem->{name};
	
	if( $wname ~~ @_muted_chans )
	{
		@_muted_chans = grep { $_ ne $wname } @_muted_chans;
	}
	else
	{
		push( @_muted_chans, $wname );
	}
	
	Irssi::statusbar_items_redraw( 'osd' );
}


sub is_muted  
	# returns bool
{
	my $channel = shift;  # string
	return grep { $_ eq $channel } @_muted_chans;
}


sub sig_text_printed
	# returns void
{
	my $dest     = shift;  # Irssi::UI::TextDest
	my $text     = shift;  # ?
	my $stripped = shift;  # string "<nick> message"
	my $channel  = $dest->{target};
	
	return if not $dest->{level} & MSGLEVEL_PUBLIC;
	return if is_muted( $channel );
	return if !is_osd_sensible_now();
	
	
	# Prepare message:
	my $headline = $channel;
	my $message  = $stripped;
	if( !($dest->{level} & MSGLEVEL_ACTIONS) )
	{
		(my $nick, $message) = $stripped =~ /^\<\W?([^\>]+)\>(.*)$/s;
		$headline            = "$nick ($channel):";
	}
	
	my $max_msg_lines     = $_osd->get_number_lines() - 1;
	my @multiline_message = $message =~ /(.{0,\Q$_osd_width\E}(?:\b|$))/gms;
	
	
	$multiline_message[2] .= '...' if length( $message ) > $_osd_width * $max_msg_lines;
	my @output = ($headline, @multiline_message);

	
	# Print message:
	$_osd->set_colour ( get_channel_color( $channel ) );
	$_osd->set_timeout( length $stripped < 50 ? 4 : 8 );
	
	$#output = $_osd->get_number_lines() - 1;  # will overwrite all lines
	my $line_index = 0;
	$_osd->string( $line_index++, $_ ) foreach (@output);
}




