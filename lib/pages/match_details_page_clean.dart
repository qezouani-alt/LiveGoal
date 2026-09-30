import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_football_service.dart';

class MatchDetailsPage extends StatefulWidget {
  final Match match;

  const MatchDetailsPage({super.key, required this.match});

  @override
  State<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  MatchDetails? _matchDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatchDetails();
  }

  Future<void> _loadMatchDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await ApiFootballService.getMatchDetails(widget.match.id);
      setState(() {
        _matchDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF002366)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '${widget.match.homeTeam.name} vs ${widget.match.awayTeam.name}',
            style: const TextStyle(
              color: Color(0xFF002366),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.info_outline)),
              Tab(text: 'Lineups', icon: Icon(Icons.people)),
              Tab(text: 'Events', icon: Icon(Icons.sports_soccer)),
            ],
            labelColor: Color(0xFF002366),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF002366),
          ),
        ),
        body: Stack(
          children: [
            // White Background with Colorful Dots
            _buildElegantBackground(),
            // Main Content
            SafeArea(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorWidget()
                      : TabBarView(
                          children: [
                            _buildOverviewTab(),
                            _buildLineupsTab(),
                            _buildEventsTab(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading match details',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMatchDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_matchDetails == null) {
      return const Center(child: Text('No match details available'));
    }

    return SingleChildScrollView(
      child: Column(
                  children: [
            _buildMatchHeader(),
            _buildMatchStats(),
            _buildRecentForm(),
            _buildHeadToHead(),
            _buildStandings(),
          ],
      ),
    );
  }

  Widget _buildLineupsTab() {
    if (_matchDetails == null || _matchDetails!.lineups.isEmpty) {
      return const Center(child: Text('No lineup information available'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Team lineups without pitch
          for (var lineup in _matchDetails!.lineups)
            _buildTeamLineupDetails(lineup.team.name, lineup),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    if (_matchDetails == null || _matchDetails!.events.isEmpty) {
      return const Center(child: Text('No events available for this match'));
    }

    return ListView.builder(
      itemCount: _matchDetails!.events.length,
      itemBuilder: (context, index) {
        final event = _matchDetails!.events[index];
        return _buildEventItem(event);
      },
    );
  }

  Widget _buildElegantBackground() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 8),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: CustomPaint(
            painter: ColorfulDotsPainter(value),
            size: Size.infinite,
          ),
        );
      },
      onEnd: () {
        // Animation completed, will restart automatically
      },
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF002366).withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002366).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // League Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    widget.match.league.logo,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.emoji_events,
                        size: 12,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.match.league.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Teams and Score
          Row(
            children: [
              // Home Team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          widget.match.homeTeam.logo,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.match.homeTeam.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              
              // Score
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.match.score?.home ?? 0} - ${widget.match.score?.away ?? 0}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Away Team
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          widget.match.awayTeam.logo,
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.match.awayTeam.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF002366).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002366).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Information',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Date', widget.match.date),
          _buildInfoRow('Time', widget.match.time),
          _buildInfoRow('Status', widget.match.status),
          _buildInfoRow('Venue', widget.match.venue),
          _buildInfoRow('League', widget.match.league.name),
          _buildInfoRow('Country', widget.match.league.country),
          _buildInfoRow('Season', '${widget.match.league.season}'),
          _buildInfoRow('Round', widget.match.league.round),
        ],
      ),
    );
  }

  Widget _buildRecentForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF002366).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002366).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Form',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // Home Team Form
          _buildTeamForm(widget.match.homeTeam.name, _getDemoForm()),
          const SizedBox(height: 16),
          
          // Away Team Form
          _buildTeamForm(widget.match.awayTeam.name, _getDemoForm()),
        ],
      ),
    );
  }

  Widget _buildTeamForm(String teamName, List<String> form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: form.map((result) => _buildFormIndicator(result)).toList(),
        ),
      ],
    );
  }

  Widget _buildFormIndicator(String result) {
    Color color;
    switch (result.toLowerCase()) {
      case 'w':
        color = Colors.green;
        break;
      case 'd':
        color = Colors.orange;
        break;
      case 'l':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          result.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<String> _getDemoForm() {
    return ['W', 'D', 'L', 'W', 'W'];
  }

  Widget _buildHeadToHead() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF002366).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002366).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Head to Head',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildH2HStats(),
        ],
      ),
    );
  }

  Widget _buildH2HStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildH2HCard('${widget.match.homeTeam.name} Wins', '3', Colors.blue),
        _buildH2HCard('Draws', '2', Colors.orange),
        _buildH2HCard('${widget.match.awayTeam.name} Wins', '1', Colors.red),
      ],
    );
  }

  Widget _buildH2HCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStandings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF002366).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002366).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'League Standings',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildStandingsTable(),
        ],
      ),
    );
  }

  Widget _buildStandingsTable() {
    return Column(
      children: [
        _buildStandingsHeader(),
        const SizedBox(height: 8),
        _buildStandingsRow('1', 'Arsenal', '15', '12', '2', '1', '38'),
        _buildStandingsRow('2', 'Manchester City', '14', '11', '2', '1', '35'),
        _buildStandingsRow('3', 'Liverpool', '13', '10', '2', '1', '32'),
        _buildStandingsRow('4', widget.match.homeTeam.name, '12', '9', '2', '1', '29'),
        _buildStandingsRow('5', widget.match.awayTeam.name, '11', '8', '2', '1', '26'),
      ],
    );
  }

  Widget _buildStandingsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('Pos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 3, child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 30, child: Text('P', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 30, child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 30, child: Text('D', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 30, child: Text('L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 30, child: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildStandingsRow(String pos, String team, String played, String won, String drawn, String lost, String points) {
    final isCurrentTeam = team == widget.match.homeTeam.name || team == widget.match.awayTeam.name;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentTeam ? Colors.blue.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(pos, style: TextStyle(fontSize: 12, fontWeight: isCurrentTeam ? FontWeight.bold : FontWeight.normal))),
          Expanded(flex: 3, child: Text(team, style: TextStyle(fontSize: 12, fontWeight: isCurrentTeam ? FontWeight.bold : FontWeight.normal))),
          SizedBox(width: 30, child: Text(played, style: TextStyle(fontSize: 12))),
          SizedBox(width: 30, child: Text(won, style: TextStyle(fontSize: 12))),
          SizedBox(width: 30, child: Text(drawn, style: TextStyle(fontSize: 12))),
          SizedBox(width: 30, child: Text(lost, style: TextStyle(fontSize: 12))),
          SizedBox(width: 30, child: Text(points, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLineupDetails(String title, Lineup lineup) {
    // Determine team color based on team name or ID
    final isHomeTeam = lineup.team.id == widget.match.homeTeam.id;
    final teamColor = isHomeTeam ? Colors.blue : Colors.red;
    final lightTeamColor = isHomeTeam ? Colors.blue.shade50 : Colors.red.shade50;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF002366).withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002366).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team header with color
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: lightTeamColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: teamColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: teamColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Starting XI
          _buildElegantLineupCategory('Starting XI', lineup.starting, teamColor),
          const SizedBox(height: 16),
          
          // Substitutes
          _buildElegantLineupCategory('Substitutes', lineup.substitutes, teamColor),
          const SizedBox(height: 16),
          
          // Coach
          if (lineup.coach.isNotEmpty) ...[
            _buildElegantLineupCategory('Coach', lineup.coach, teamColor),
          ],
        ],
      ),
    );
  }

  Widget _buildElegantLineupCategory(String title, List<Player> players, Color teamColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: teamColor,
          ),
        ),
        const SizedBox(height: 12),
        
        if (players.isEmpty) ...[
          Text(
            'No players available',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ] else ...[
          Container(
            decoration: BoxDecoration(
              color: teamColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: teamColor.withValues(alpha: 0.2)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: players.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: teamColor.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final player = players[index];
                return _buildElegantPlayerItem(player, teamColor);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildElegantPlayerItem(Player player, Color teamColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Player number in circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: teamColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${player.number}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  player.position,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Position indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPositionColor(player.position),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getPositionAbbreviation(player.position),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(String position) {
    switch (position.toLowerCase()) {
      case 'gk':
        return Colors.orange;
      case 'd':
      case 'def':
        return Colors.blue;
      case 'm':
      case 'mid':
        return Colors.green;
      case 'f':
      case 'fw':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPositionAbbreviation(String position) {
    switch (position.toLowerCase()) {
      case 'gk':
        return 'GK';
      case 'd':
      case 'def':
        return 'DEF';
      case 'm':
      case 'mid':
        return 'MID';
      case 'f':
      case 'fw':
        return 'FWD';
      default:
        return position.toUpperCase();
    }
  }

  Widget _buildEventItem(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF002366).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002366).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Event Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getEventColor(event.type),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getEventIcon(event.type),
              color: Colors.white,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event type
                Text(
                  event.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getEventColor(event.type),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Player information based on event type
                if (event.type.toLowerCase() == 'subst' || event.type.toLowerCase() == 'substitution') ...[
                  if (event.playerOut != null && event.playerIn != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          // OUT Sign
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OUT',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Player going out
                          Expanded(
                            child: Text(
                              '${event.playerOut!.name} (${event.playerOut!.number})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Arrow
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          // IN Sign
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'IN',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Player coming in
                          Expanded(
                            child: Text(
                              '${event.playerIn!.name} (${event.playerIn!.number})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (event.player != null) ...[
                    Text(
                      '${event.player!.name} (${event.player!.number})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ]
                ] else if (event.type.toLowerCase() == 'goal' && event.player != null) ...[
                  Text(
                    '${event.player!.name} (${event.player!.number})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ] else if (event.player != null) ...[
                  Text(
                    '${event.player!.name} (${event.player!.number})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
                
                // Assist information (only for goals)
                if (event.type.toLowerCase() == 'goal' && event.assist != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Assist: ${event.assist!.name} (${event.assist!.number})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
                
                if (event.comments != null && event.comments!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.comments!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Time
          Text(
            '${event.time}\'',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'goal':
        return Icons.sports_soccer;
      case 'yellow card':
      case 'card':
        return Icons.credit_card;
      case 'red card':
        return Icons.block;
      case 'substitution':
      case 'subst':
        return Icons.swap_vert;
      case 'var':
        return Icons.video_library;
      case 'penalty':
        return Icons.sports_soccer;
      case 'foul':
        return Icons.warning;
      case 'corner':
        return Icons.turn_right;
      case 'free kick':
        return Icons.sports_soccer;
      case 'offside':
        return Icons.flag;
      case 'injury':
        return Icons.healing;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'goal':
        return Colors.green;
      case 'yellow card':
      case 'card':
        return Colors.orange;
      case 'red card':
        return Colors.red;
      case 'substitution':
      case 'subst':
        return Colors.purple;
      case 'var':
        return Colors.purple;
      case 'penalty':
        return Colors.green;
      case 'foul':
        return Colors.orange;
      case 'corner':
        return Colors.indigo;
      case 'free kick':
        return Colors.teal;
      case 'offside':
        return Colors.deepOrange;
      case 'injury':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Custom painter for football pitch markings
class PitchMarkingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      30,
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Penalty areas
    // Left penalty area
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width * 0.3, size.height * 0.4),
      paint,
    );

    // Right penalty area
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.6, size.width * 0.3, size.height * 0.4),
      paint,
    );

    // Goal areas
    // Left goal area
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width * 0.15, size.height * 0.3),
      paint,
    );

    // Right goal area
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.85, size.height * 0.7, size.width * 0.15, size.height * 0.3),
      paint,
    );

    // Corner arcs
    final cornerRadius = 15.0;
    
    // Top-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
      0,
      math.pi / 2,
      false,
      paint,
    );

    // Top-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerRadius * 2, 0, cornerRadius * 2, cornerRadius * 2),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );

    // Bottom-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerRadius * 2, size.height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
      3 * math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Responsive pitch markings painter for different screen sizes
class ResponsivePitchMarkingsPainter extends CustomPainter {
  final double pitchSize;
  
  ResponsivePitchMarkingsPainter(this.pitchSize);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = (pitchSize * 0.005).clamp(1.0, 3.0) // Responsive stroke width
      ..style = PaintingStyle.stroke;

    final pitchHeight = size.height;
    final centerX = size.width / 2;
    final centerY = pitchHeight / 2;
    
    // Adjust penalty areas for smaller pitch height
    final penaltyAreaHeight = pitchHeight * 0.4;
    final goalAreaHeight = pitchHeight * 0.3;
    
    // Center circle
    final centerCircleRadius = (pitchSize * 0.075).clamp(20.0, 40.0);
    canvas.drawCircle(
      Offset(centerX, centerY),
      centerCircleRadius,
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, pitchHeight),
      paint,
    );

    // Penalty areas
    // Left penalty area
    canvas.drawRect(
      Rect.fromLTWH(0, pitchHeight * 0.6, size.width * 0.3, penaltyAreaHeight),
      paint,
    );

    // Right penalty area
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, pitchHeight * 0.6, size.width * 0.3, penaltyAreaHeight),
      paint,
    );

    // Goal areas
    // Left goal area
    canvas.drawRect(
      Rect.fromLTWH(0, pitchHeight * 0.7, size.width * 0.15, goalAreaHeight),
      paint,
    );

    // Right goal area
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.85, pitchHeight * 0.7, size.width * 0.15, goalAreaHeight),
      paint,
    );

    // Corner arcs
    final cornerRadius = (pitchSize * 0.0375).clamp(10.0, 25.0);
    
    // Top-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
      0,
      math.pi / 2,
      false,
      paint,
    );

    // Top-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerRadius * 2, 0, cornerRadius * 2, cornerRadius * 2),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );

    // Bottom-left corner
    canvas.drawArc(
      Rect.fromLTWH(0, pitchHeight - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerRadius * 2, pitchHeight - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
      3 * math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Colorful Dots Painter for white background with floating dots
class ColorfulDotsPainter extends CustomPainter {
  final double animationValue;

  ColorfulDotsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw colorful floating dots
    _drawColorfulDots(canvas, size, paint);
  }

  void _drawColorfulDots(Canvas canvas, Size size, Paint paint) {
    // Create colorful floating dots
    for (int i = 0; i < 20; i++) {
      final x = (i * 150.0 + animationValue * 100) % size.width;
      final y = (i * 100.0 + animationValue * 80) % size.height;
      final dotSize = 1.5 + (i % 3) * 1.0;
      
      // Different movement patterns for natural floating
      final movementX = math.sin(animationValue * 1.2 * 3.14159 + i) * 40;
      final movementY = math.cos(animationValue * 1.8 * 3.14159 + i) * 30;
      
      final dotX = (x + movementX) % size.width;
      final dotY = (y + movementY) % size.height;
      
      // Colorful dots with different colors
      final colors = [
        const Color(0xFFFF6B6B), // Red
        const Color(0xFF4ECDC4), // Teal
        const Color(0xFF45B7D1), // Blue
        const Color(0xFF96CEB4), // Green
        const Color(0xFFFECA57), // Yellow
        const Color(0xFFFF9FF3), // Pink
        const Color(0xFF54A0FF), // Light Blue
        const Color(0xFF5F27CD), // Purple
        const Color(0xFFFF9F43), // Orange
        const Color(0xFF00D2D3), // Cyan
      ];
      
      final color = colors[i % colors.length];
      
      // Add twinkling effect
      final twinkle = (math.sin(animationValue * 3 * 3.14159 + i) + 1) / 2;
      final alpha = 0.6 + twinkle * 0.4;
      
      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(dotX, dotY), dotSize, paint);
      
      // Add subtle glow effect
      paint.color = color.withValues(alpha: 0.1);
      canvas.drawCircle(Offset(dotX, dotY), dotSize * 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
