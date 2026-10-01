import 'package:flutter/material.dart';
import '../services/api_football_service.dart';

class MatchListWidget extends StatefulWidget {
  final String date;
  
  const MatchListWidget({
    super.key,
    required this.date,
  });

  @override
  State<MatchListWidget> createState() => _MatchListWidgetState();
}

class _MatchListWidgetState extends State<MatchListWidget> {
  List<Match> _matches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  @override
  void didUpdateWidget(MatchListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadMatches();
    }
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matches = await ApiFootballService.getMatchesByDate(widget.date);
      setState(() {
        _matches = matches;
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
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
              'Error loading matches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMatches,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No matches today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no matches scheduled for ${widget.date}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return _buildMatchCard(match);
        },
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // League header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Image.network(
                  match.league.logo,
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_events,
                      size: 20,
                      color: Colors.grey[600],
                    );
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.league.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(match.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Match content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Home team
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(match.homeTeam.logo),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: match.homeTeam.logo.isEmpty
                            ? Text(
                                match.homeTeam.name.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.homeTeam.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Score and time
                Expanded(
                  child: Column(
                    children: [
                      if (match.score != null) ...[
                        Text(
                          '${match.score!.home ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '-',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${match.score!.away ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          match.time,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        match.venue,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Away team
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(match.awayTeam.logo),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: match.awayTeam.logo.isEmpty
                            ? Text(
                                match.awayTeam.name.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.awayTeam.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
      case '1h':
      case '2h':
        return Colors.red;
      case 'ft':
      case 'aet':
      case 'pen':
        return Colors.green;
      case 'ns':
      case 'tbd':
        return Colors.blue;
      case 'cancelled':
      case 'postponed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
