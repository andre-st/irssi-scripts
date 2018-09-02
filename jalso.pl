# /SCRIPT [UN]LOAD jalso.pl
# /JALSO [-YES]
# /JALSO CANCEL
# 
# Irssi script that lists channels visited by the users from the active channel
#
# PURPOSE:
#	1. discover new channels, 
#	   e.g., partner and sub-channels, channels visited by people 
#	   with interests similar to yours
#	2. discover groups or milieus in the active channel, 
#	   e.g., 20% developers or 10% anarchists
#
# EXAMPLE OUTPUT:
#	Users here also joined:
#	#math   #java   #c         #computerbase  #physic   #electronics
#	#LaTeX  #mysql  #hardware  #perl          #history  #linux
#	#d      #edu    #windows   #startups
#
# INSTALL:
# 	- put this script under ~/.irssi/scripts/autorun
#
# OBSERVATIONS:
#	- useless on Freenode since 2010-05-08:
#	  "+i wasn't set for all users by default until earlier this year 
#	  when ircd-seven replaced hyperion"
#	  however: most networks dont limit WHOIS by +i (QuakeNet, EFnet, ...)
#	- slow: 36 users->1 minute, 96->4, 300->11
#	- avoid /whois while /jalso is running (ub?)
#	- ...
#	- good result diversity: #language -> #tools, #libs, #projects, 
#	  #otherLanguages, #aspects (#security, #math, #electronics), 
#	  #culture (#26c3, #startups)
#	- the most interesting channels (on a familiar network) were listed 
#	  in the mid or lower range of counted visitors; 
#	  top range offers already known channels or partner/sub-chans
#	- usage frequency: only once in known and new channels, that is,
#	  not that often, but sometimes it's good to have
#	- helpful on exploring new networks, starting from #euirc, #lobby or similar
#	- helps on finding channels during social events: 
#		e.g., during Mubarak-riots, #egypt was the first channel that
#		came to my mind. I ran this script and discovered 
#		#cairo, #israel, #middle_east and other related channels
#	=> start with a (bad) channel choice, then refine via script, e.g., DALnet
#		#webdesign -> #webdev, #xhtml, #css, #javascript, #eyestrain
#
# ASSUMPTIONS:
#	- there is a vast number of channels (39K IRCnet, 63K QuakeNet)
#		- sometimes you don't know what you can have,
#		  so you won't search for it (unknown unknowns)
#	- users collaboratively explore these channels over time
#		-> different or distributed knowledge as resource
#	- users usually don't stay in waste channels
#		-> their channel list (WHOIS) is a sort of recommendation: 
#		   "these channels are worth my time and attention"
#	- you're in a channel together with (and because of) 
#	  people who probably share your interests or mindset 
#		-> somehow related channels might also match your interests
#	- affinity of channel X to Y heuristically appears in
#	  the number of users in X also visiting Y
#	- affinity is technical, sociocultural, spatial, ...
#	- ...
#	- a present WHOIS service
#	- a significant number of users not hiding their channel list
#
# OPERATION BREAKDOWN:
# 	1. get relevant nicks in active channel
# 	2. WHOIS every nick for his channel list
#	3. sum up visits of each channel
#	4. sort channels by their number of visitors in descending order
# 	5. output channels
#	
# TODO:
#	- output estimated runtime "at 20:43" instead of "in 5 minutes"
#	- estimate runtime on the basis of the actual performance
#		if formular doesn't work for other ppl/netw
#	- try without flood protection (send_raw_now), performance?
#	- improve get_relevant_nicks
#		- name variations (ghosts)
#		- drop duplicate users with same hostmask (test in irc.icq.com)
# 


use v5.8.8;
use strict;
use POSIX;     # ceil
use Irssi;
use List::Util qw(max);

our $VERSION = '2018-09-02';
our %IRSSI = 
(
	authors     => 'http://datakadabra.wordpress.com',
	contact     => 'datakadabra@gmail.com',
	url         => 'https://github.com/andre-st/irssi-scripts',
	name        => 'jalso',
	description => 'List channels visited by the users from the active channel',
	created     => '2009-12-10',
	changed     => $VERSION,
	license     => 'CC-BY-SA',
	commands    => 'jalso',
);


our $_num_actual_surveyed = 0;      # 'actual' in terms of WHOIS errors i.a.
our @_unsurveyed_nicks    = undef;  # string array
our %_num_visitors_in     = undef;  # in channel (string key)
our $_target_channel      = undef;  # Irssi::Irc::Channel
our $_is_running          = 0;      # prevents duplicate/concurrent runs (singleton)
our $_is_canceled         = 0;      # flag indicates survey to stop


Irssi::command_bind('jalso', 'jalso_command_entered');


sub get_runtime_estimate  
	# returns int minutes
{
	my $channel = shift; # Irssi::Irc::Channel
	my @nicks   = $channel->nicks();
	
	# runtime is O(n)
	# slope and intercept was computed from samples (jalso.ods)
	#
	return int( 0.5 + ( 0.04 * @nicks ) + 0.02 );  # rounded
}


sub get_error  
	# returns string or undef if no complaint
{
	my $channel  = shift;  # Irssi::Irc::Windowitem
	my $cmd_args = shift;  # string
	my $may_warn = not $cmd_args =~ /-yes/i;
	
	
	if(!$channel 
	or  $channel->{type}      ne 'CHANNEL'
	or  $channel->{chat_type} ne 'IRC')
	{
		return 'Call /JALSO in an IRC channel';
	}
	
	return 'Still canceling the last survey. Be patient.'  if( $_is_running && $_is_canceled );
	return 'Last survey is to complete. Try /JALSO CANCEL' if( $_is_running );
	return 'Retry after channel is fully synchronized'     if(!$channel->{synced} );
	return 'Doesn\'t work with: Freenode.'                 if( $channel->{server}->{chatnet} eq 'freenode' );
	
	my $runtime_minutes = get_runtime_estimate( $channel );
	
	return "This will take approx. $runtime_minutes minutes. Add -YES option to command if you really mean it."
			if( $may_warn && $runtime_minutes > 1 );
	
	
	return undef;
}


sub print_summary
{	
	my @sorted_channel_names = sort { $_num_visitors_in{$b} <=> $_num_visitors_in{$a} } keys %_num_visitors_in;
	my $column_width         = max map length, @sorted_channel_names;
	   $column_width         = 18 if $column_width > 18;  # don't waste visual space
	my($summary, $num, $share, $pad_len);
	
	foreach my $channel (@sorted_channel_names)
	{
		$num      = $_num_visitors_in{$channel};
		$share    = int( 0.5 + ( ( $num / $_num_actual_surveyed ) * 100 ) );
		$pad_len  = ceil( ( length $channel ) / $column_width ) * $column_width;
		$channel  = pack( "A$pad_len", $channel );
		$summary .=   "%c$channel%c"    if $share <   5                   ||  $num == 1;
		$summary .= "%c%9$channel%9%c"  if $share >=  5  &&  $share < 20  &&  $num >  1;
		$summary .= "%w%9$channel%9%w"  if $share >= 20  &&  $share < 40  &&  $num >  1;
		$summary .= "%g%9$channel%9%g"  if $share >= 40                   &&  $num >  1;
	}
	
	my $legend = '%8%g%9 40%+ %9%g%w%9 20%+ %9%w%c%9  5%+ %9%c%c  1+  %c%8';
	$summary   = '%9nothing%9' if !$summary;
	
	$_target_channel->print( $legend . '%w users here also joined:%w', MSGLEVEL_MSGS );
	$_target_channel->print( '%|' . $summary,                          MSGLEVEL_MSGS );
}


sub survey_finished
{
	Irssi::signal_remove( 'redir individual_channels_elicited', 'individual_channels_elicited' );
	Irssi::signal_remove( 'redir unsurveyed_nicks_left',        'unsurveyed_nicks_left'        );
	
	if( $_is_canceled )
	{
		$_target_channel->print( 'Survey canceled.' );
	}
	else
	{
		print_summary();
	}
	
	$_is_running  = 0;
	$_is_canceled = 0;
}


sub individual_channels_elicited
{
	my $server        = shift;                           # Irssi::Irc::Server
	my @channel_names = shift =~ /\#[\#a-zA-Z0-9_-]+/g;  # string with names + clutter
	$_num_actual_surveyed++;
	
	foreach my $channel (@channel_names)
	{
		$_num_visitors_in{$channel}++ if $channel ne $_target_channel->{name};
	}
}


sub unsurveyed_nicks_left
{
	my $server = $_target_channel->{server};
	my $nick   = pop @_unsurveyed_nicks;
	
	if( !$nick || $_is_canceled )
	{
		survey_finished();
		return;
	}
	
	# We chain WHOIS requests rather than dump the entire lot in a loop
	# so server_queue is not going to be full of whois response.
	#
	$server->redirect_event( 'whois', 1, $nick, 0, undef, {
			'event 319' => 'redir individual_channels_elicited',
			'event 318' => 'redir unsurveyed_nicks_left',  # end of whois
			'event 401' => 'redir unsurveyed_nicks_left',  # no such nick
			''          => 'event empty'} );
	
	$server->send_raw( "WHOIS :$nick" );
}


sub get_relevant_nicks  
	# returns string array with hopefully fewer nicks
	# in order to improve survey quality (duplicates)
	# as well as performance (number of WHOIS requests)
{
	my $channel = shift;                                 # Irssi::Irc::Channel
	my @nicks   = map { $_->{nick} } $channel->nicks();  # string array easens work
	
	# Drop my nick and my channels as I already know them
	#
	@nicks = grep { $_ ne $channel->{server}->{nick} } @nicks;
	
	# Drop ghosts by eliminating nick variations
	# 'nick__' kills 'nick_' kills 'nick'
	#
	@nicks = grep { not grep /\Q$_\E[_\-0-9|]/, @nicks } @nicks;

	return @nicks;
}


sub jalso_command_entered
{
	my $args   = shift;  # string
	my $server = shift;  # Irssi::Irc::Server
	my $witem  = shift;  # Irssi::Irc::Windowitem
	
	if( $args =~ /cancel/i )
	{
		$_is_canceled = 1;  # Signal to event handler
		return;
	}
	
	my $error = get_error( $witem, $args );
	if( $error )
	{
		Irssi::active_win()->print( $error );
		return;
	}
	
	$_is_running          = 1;
	$_is_canceled         = 0;
	$_num_actual_surveyed = 0;
	%_num_visitors_in     = ();
	$_target_channel      = $witem;
	@_unsurveyed_nicks    = get_relevant_nicks( $_target_channel );
	
	Irssi::signal_add( 'redir individual_channels_elicited', 'individual_channels_elicited' );
	Irssi::signal_add( 'redir unsurveyed_nicks_left',        'unsurveyed_nicks_left'        );
	
	$_target_channel->print( 'Survey is running...' );
	
	unsurveyed_nicks_left();
}



